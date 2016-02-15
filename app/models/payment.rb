
# Payment class helps interact with Active Merchant via different Payment Gateways.
# It's now isolated from Reservation, Order etc. All you need to do to add payment
# to new model is to build payment object (see build_payment method in Reservation class).
# CreditCardForm object is required to process CC authorization.
# To create valid Payment object it's necessary to pass PaymentMethod that describe payment type
#
# Manual and free payments are now created so it can be taken into statistics in the future.
#
# There are serveral flow methods that can be invoked on Payment object:
#
# - authorize:
#     - validates CC/Token if needed
#     - authorize via appropriate PaymentAuthorizer class, BillingAuthorization with
#       token returned from Gateway call is saved. We do not persist failed authorizations.
#     - store card token if PaymentGateway supports that option
#
# - void!:
#     - release frozen money, and marks payment as "voided"
#     - failed void does not block Reservation status change
#
# - capture!:
#     - create Charge object with capture response. If successful moves money from buyer to
#       primary receiver. In chained transactions, after successful capture, second trasaction
#       is created with service fee for MPO
#     - failed capture BLOCKS Reservation status chage, TODO we could add fallback: "We failed to
#       capture payment, do you wish to confirm that resrevation anyway?" in modal box.
#
# - refund!
#     - refund method is invoked by PaymentRefundJob that first call refund! method
#       where 3 attempts are executed. Payment#amount_to_be_refunded method determines amount
#       that is refunded.
#     - failed refund does not block Reservation status chage


class Payment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  attr_accessor :express_checkout_redirect_url, :payment_response_params, :payment_method_nonce, :customer

  # === Associations

  belongs_to :company, -> { with_deleted }
  belongs_to :instance
  belongs_to :payment_transfer
  belongs_to :payment_gateway
  belongs_to :payment_method
  belongs_to :merchant_account
  # Payable association connects Payment with Reservation and Spree::Order
  belongs_to :payable, polymorphic: true

  has_many :billing_authorizations
  has_many :charges, dependent: :destroy
  has_many :refunds

  has_one :successful_billing_authorization, -> { where(success: true) }, class_name: BillingAuthorization
  has_one :successful_charge, -> { where(success: true) }, class_name: Charge

  before_validation :set_offline

  # === Scopes

  scope :active, -> { where(state: ['authorized', 'paid'])}
  scope :live, -> { where(payment_gateway_mode: 'live')}
  scope :authorized, -> { where(state: 'authorized') }
  scope :paid, -> { where("#{table_name}.state = 'paid'") }
  scope :paid_or_refunded, -> { where(state: ['paid', 'refunded']) }
  scope :refunded, -> { where("#{table_name}.state = 'refunded'") }
  scope :not_refunded, -> { where("#{table_name}.state IS NOT 'refunded'") }
  scope :last_x_days, lambda { |days_in_past|
    where('DATE(payments.created_at) >= ? ', days_in_past.days.ago)
  }

  scope :needs_payment_transfer, -> {
    paid_or_refunded.where(payment_transfer_id: nil, offline: false)
  }

  scope :total_by_currency, -> {
    paid.group('payments.currency').
    select('
        payments.currency,
        SUM(
          payments.subtotal_amount_cents
          + payments.service_fee_amount_guest_cents
        )
           ')
  }


  validates :currency, presence: true
  validates :payment_gateway, presence: true
  validates :payment_method, presence: true
  validates :payable_id, :uniqueness => { :scope => [:payable_type, :payable_id, :instance_id] }, if: Proc.new {|p| p.payable_id.present? }

  # === Helpers
  monetize :subtotal_amount_cents, with_model_currency: :currency
  monetize :service_fee_amount_guest_cents, with_model_currency: :currency
  monetize :service_fee_amount_host_cents, with_model_currency: :currency
  monetize :total_service_fee_cents, with_model_currency: :currency
  monetize :total_amount_cents, with_model_currency: :currency
  monetize :total_additional_charges_cents, with_model_currency: :currency
  monetize :service_additional_charges_cents, with_model_currency: :currency
  monetize :host_additional_charges_cents, with_model_currency: :currency

  delegate :subject, to: :merchant_account, allow_nil: true

  state_machine :state, initial: :pending do
    event :mark_as_authorized do transition pending: :authorized; end
    event :mark_as_paid       do transition authorized: :paid; end
    event :mark_as_voided     do transition authorized: :voided; end
    event :mark_as_refuneded  do transition paid: :refunded; end
  end

  def authorize
    !!(valid_for_authorization? && payment_gateway.authorize(self, auth_options) && store_card)
  end

  def capture!
    return true if manual_payment? || total_amount_cents == 0
    return false unless active_merchant_payment?

    charge = payment_gateway.charge(payable.owner, total_amount.cents, currency, self, authorization_token)

    if charge.success?
      if payable.respond_to?(:date)
        ReservationChargeTrackerJob.perform_later(payable.date.end_of_day, payable.id)
      end
      # this works for braintree, might not work for others - to be moved to separate class etc, and ideally somewhere else... hackish hack as a quick win
      update_attribute(:external_transaction_id, payable.try(:billing_authorization).try(:response).try(:authorization))
      mark_as_paid!
    else
      touch(:failed_at)
      false
    end
  end

  def refund!
    return false if refunded?
    return false if paid_at.nil? && !paid?
    return false if amount_to_be_refunded <= 0
    return false if !active_merchant_payment?

    # Because Braintree Marketplace refund pull funds from MPO account
    # we want to block it until the right approach is integrated.
    # Here are several ideas how to deal with the problem:
    # https://articles.braintreepayments.com/guides/marketplace/processing#collecting-funds-from-your-sub-merchants

    return false if PaymentGateway::BraintreeMarketplacePaymentGateway === payment_gateway

    # We need to abort payout in case seller was already paid out
    # This should be resolved together with Braintree with CC subscription for sellers
    return false if transferred_to_seller? && !immediate_payout?

    refund = payment_gateway.refund(amount_to_be_refunded, currency, self, successful_charge)
    if refund.success?
      mark_as_refuneded!
      true
    else
      touch(:failed_at)

      if should_retry_refund?
        PaymentRefundJob.perform_later(retry_refund_at, id)
      else
        Rails.application.config.marketplace_error_logger.log_issue(MarketplaceErrorLogger::BaseLogger::REFUND_ERROR, "Refund for Reservation id=#{self.id} failed #{refund_attempts} times, manual intervation needed.")
      end

      false
    end
  end

  def void!
    return false unless authorized?
    return false unless active_merchant_payment?
    return false if successful_billing_authorization.blank?

    response = payment_gateway.void(self)
    successful_billing_authorization.void_response = response

    if response.success?
      mark_as_voided!
      successful_billing_authorization.touch(:void_at)
    else
      successful_billing_authorization.save!
    end
  end

  def credit_card_form=(credit_card_attributes)
    @credit_card_form = CreditCardForm.new(credit_card_attributes)
  end

  def credit_card_form
    @credit_card_form ||= CreditCardForm.new
  end

  def credit_card
    @credit_card_form.try(:to_active_merchant)
  end

  def total_amount_cents
    subtotal_amount.cents + service_fee_amount_guest.cents + total_additional_charges.cents
  end

  def total_additional_charges_cents
    service_additional_charges_cents + host_additional_charges_cents
  end

  def subtotal_amount_cents_after_refund
    result = nil

    if self.payable.respond_to?(:cancelled_by_host?) && self.payable.cancelled_by_host?
      result = 0
    else
      result = subtotal_amount.cents + host_additional_charges.cents - refunds.successful.sum(:amount)
    end

    result
  end

  def final_service_fee_amount_host_cents
    result = self.service_fee_amount_host.cents

    if (self.payable.respond_to?(:cancelled_by_host?) && self.payable.cancelled_by_host?) || (self.payable.respond_to?(:cancelled_by_guest?) && self.payable.cancelled_by_guest?)
      result = 0
    end

    result
  end

  def final_service_fee_amount_guest_cents
    result = self.service_fee_amount_guest.cents + self.service_additional_charges.cents

    if self.payable.respond_to?(:cancelled_by_host?) && self.payable.cancelled_by_host?
      result = 0
    end

    result
  end

  def total_service_fee_cents
    final_service_fee_amount_host_cents + final_service_fee_amount_guest_cents
  end

  def amount
    total_amount
  end

  def amount_to_be_refunded
    if cancelled_by_guest? && payment_gateway.supports_partial_refunds?
      (subtotal_amount.cents * (1 - self.cancellation_policy_penalty_percentage.to_f/BigDecimal(100))).to_i
    else
      total_amount.cents
    end
  end

  def cancelled_by_guest?
    payable.respond_to?(:cancelled_by_guest?) && payable.cancelled_by_guest?
  end

  # TODO: now as we call that on Payment object there is no need to _payment?, instead payment.manual?
  PaymentMethod::PAYMENT_METHOD_TYPES.each do |pmt|
    define_method("#{pmt}_payment?") { self.payment_method.try(:payment_method_type) == pmt.to_s }
  end

  def payment_methods
    payment_gateways = PlatformContext.current.instance.payment_gateways(company.iso_country_code, currency)
    if is_free?
      payment_gateways.map(&:active_free_payment_methods)
    else
      payment_gateways.map(&:active_payment_methods)
    end.flatten.uniq
  end

  def is_free?
    total_amount.zero?
  end

  def active_merchant_payment?
    self.payment_method.try(:capturable?)
  end

  def payment_method_nonce=(token)
    return false if token.blank?
    @payment_method_nonce = token
  end

  def express_token=(token)
    write_attribute(:express_token, token)
    if !token.blank?
      details = payment_gateway.gateway(subject).details_for(token)
      self.express_payer_id = details.params["payer_id"]
    end
  end

  def redirect_to_paypal?
    express_checkout_payment? && express_checkout_redirect_url.present?
  end

  # This method remains here to make possible flawless transition after adding
  # payment_gateway_mode attribute. It can be removed a week or two after of the release.
  def payment_gateway_mode
    super || charges.successful.first.try(:payment_gateway_mode)
  end

  def payment_gateway
    @payment_gateway ||= super || payable.try(:billing_authorization).try(:payment_gateway)
  end

  def payment_method_id=(payment_method_id)
    self.payment_method = PaymentMethod.find(payment_method_id)
  end

  def payment_method=payment_method
    super(payment_method)
    self.payment_gateway = self.payment_method.payment_gateway
    self.payment_gateway_mode = self.payment_gateway.mode
    self.merchant_account = self.payment_gateway.merchant_account(company)
  end

  def authorization_token
    if self.persisted?
      successful_billing_authorization.try(:token)
    else
      billing_authorizations.select {|b| b.success? }.first.try(:token)
    end
  end

  def refund_attempts
    refunds.failed.count
  end

  def should_retry_refund?
    refund_attempts < payment_gateway.max_refund_attempts
  end

  def retry_refund_at
    self.failed_at + (refund_attempts * 6).hours
  end

  private

  # TODO: move this flague to Payment from BillingAuthorization
  def immediate_payout?
    successful_billing_authorization.try(:immediate_payout?) == true
  end

  def auth_options
    {
      customer: customer,
      order_id: payable.id
    }
  end

  def store_card
    return true unless payment_gateway.supports_recurring_payment?
    return true unless payable.respond_to?("credit_card_id=")
    return true unless credit_card_payment?

    if payable.credit_card_id = payment_gateway.store_credit_card(payable.user, credit_card)
      true
    else
      add_error(I18n.t('reservations_review.errors.internal_payment', :cc))
      false
    end
  end

  def transferred_to_seller?
    payment_transfer.try(:transferred?)
  end

  def set_offline
    self.offline = manual_payment?
    true
  end

  def valid_for_authorization?
    if credit_card_payment? && !credit_card_form.valid? && auth_options[:customer].blank?
      errors.add(:cc, I18n.t('buy_sell_market.checkout.invalid_cc'))
      false
    else
      true
    end
  end
end
