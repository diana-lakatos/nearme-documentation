# frozen_string_literal: true

class Payment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  attr_accessor :express_checkout_redirect_url, :payment_response_params, :customer,
                :recurring, :rejection_form, :public_token, :account_id, :redirect_to_gateway

  # === Associations

  # Payable association connects Payment with Reservation and Order
  belongs_to :payable, polymorphic: true
  # BankAccount/CreditCard
  belongs_to :payment_source, polymorphic: true
  belongs_to :company, -> { with_deleted }
  belongs_to :instance
  belongs_to :payment_transfer
  belongs_to :payment_method, -> { with_deleted }
  belongs_to :merchant_account
  belongs_to :payer, -> { with_deleted }, class_name: 'User'

  has_many :billing_authorizations
  has_many :authorizations, class_name: 'BillingAuthorization'
  has_many :charges, dependent: :destroy
  has_many :refunds
  has_many :line_items

  has_one :payment_gateway, -> { with_deleted }, through: :payment_method
  has_one :successful_billing_authorization, -> { where(success: true) }, class_name: BillingAuthorization
  has_one :successful_charge, -> { where(success: true) }, class_name: Charge

  before_validation :set_offline, on: :create
  before_validation :set_merchant_account, on: :create
  before_validation :set_payment_gateway_mode, on: :create

  # === Scopes

  scope :migrated_payment, -> { where('payable_type NOT IN(?)', ['OldReservation', 'OldRecurringBookingPeriod', 'Spree::Order']) }
  scope :active, -> { where(state: %w(authorized paid)) }
  scope :live, -> { where(payment_gateway_mode: 'live') }
  scope :authorized, -> { where(state: 'authorized') }
  scope :paid, -> { where("#{table_name}.state = 'paid'") }
  scope :paid_or_refunded, -> { where(state: %w(paid refunded)) }
  scope :refunded, -> { where("#{table_name}.state = 'refunded'") }
  scope :not_refunded, -> { where("#{table_name}.state IS NOT 'refunded'") }
  scope :last_x_days, ->(days_in_past) { where('DATE(payments.created_at) >= ? ', days_in_past.days.ago) }
  scope :needs_payment_transfer, -> { paid_or_refunded.where(payment_transfer_id: nil, offline: false, exclude_from_payout: false).migrated_payment }
  scope :transferred, -> { where.not(payment_transfer_id: nil) }

  scope :total_by_currency, lambda {
    paid.group('payments.currency').select('
      payments.currency,
      SUM(
        payments.subtotal_amount_cents
        + payments.service_fee_amount_guest_cents
      )
   ')
  }

  accepts_nested_attributes_for :payment_source
  accepts_nested_attributes_for :charges

  before_validation do |_p|
    self.payer ||= payable.try(:owner)
    true
  end

  validates :currency, presence: true
  validates :payment_source, presence: true, if: :require_payment_source?
  validates :payer, presence: true
  validates :payment_gateway, presence: true
  validates :payment_method, presence: true
  validates :payable_id, uniqueness: { scope: [:payable_type, :payable_id, :instance_id] }, if: proc { |p| p.payable_id.present? }

  validates_associated :payment_source, on: :create

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
  delegate :customer_id, to: :credit_card, allow_nil: true
  delegate :merchant_id, to: :merchant_account, allow_nil: true
  delegate :cancelled_by_guest?, :cancelled_by_host?, to: :payable, allow_nil: true

  state_machine :state, initial: :pending do
    after_transition any => :failed, do: :fail!

    event :mark_as_authorized do
      transition [:pending, :voided] => :authorized
    end
    event :mark_as_paid do
      transition [:pending, :failed, :authorized] => :paid
    end
    event :mark_as_voided do
      transition [:authorized, :paid] => :voided
    end
    event :mark_as_refuneded do
      transition paid: :refunded
    end
    event :mark_as_failed do
      transition any => :failed
    end
  end

  # TODO: now as we call that on Payment object there is no need to _payment?, instead payment.manual?
  PaymentMethod::PAYMENT_METHOD_TYPES.each do |pmt|
    define_method("#{pmt}_payment?") { payment_method.try(:payment_method_type) == pmt.to_s }
  end

  def process!
    return false unless valid?
    return true unless pending?
    return true unless payment_method.respond_to?(:payment_sources)
    return false if payment_source.blank?
    return generate_paypal_express_link! if express_checkout_payment? && payment_source.express_payer_id.blank?
    return false unless payment_source.process!
    return false if payment_source.authorizable? && !authorize!

    true
  end

  # authorize!
  #  sends authorize call to PaymentGateway (usually via ActiveMerchant)
  #  usually authorized amount is freezed on payment source account
  #  creates BillingAuthorization with proper state
  #  adjust Payment state accoridng to PaymentGateway response
  #  adds errors (usually passed by exteranl PaymentGateway) if something goes wrong
  #  returns true or false depending on authorization success

  def authorize!
    response = payment_gateway.gateway_authorize(total_amount.cents, source, payment_options)

    billing_authorization = billing_authorizations.build(
      received_response: response,
      payment_gateway: payment_gateway,
      reference: payable,
      immediate_payout: payment_gateway.immediate_payout(company)
    )

    if response.success?
      self.external_id ||= billing_authorization.token
      mark_as_authorized!
    else
      errors.add(:base, response.message)
      errors.add(:base, I18n.t('activemodel.errors.models.payment.attributes.base.authorization_failed'))
    end

    response.success?
  end

  # void!
  # - release frozen money, and marks payment as "voided"
  # - failed void does not block Reservation status change

  def void!
    return false unless authorized? || paid?
    return false unless active_merchant_payment?
    return false if successful_billing_authorization.blank?

    response = payment_gateway.void(self)
    successful_billing_authorization.void_response = response

    if response.success?
      mark_as_voided!
      successful_billing_authorization.touch(:void_at)
      true
    else
      successful_billing_authorization.save!
      false
    end
  end

  # capture!
  # - caputre authorized transaction - money transfer from payment source account is triggered
  # - create Charge object with capture response. If successful moves money from buyer to
  #   primary receiver. In chained transactions, after successful capture, second trasaction
  #   is created with service fee for MPO
  # - failed capture BLOCKS Reservation status chage, TODO we could add fallback: "We failed to
  #   capture payment, do you wish to confirm that resrevation anyway?" in modal box.

  def capture!
    pay_with! do
      payment_gateway.gateway_capture(total_amount.cents, authorization_token, payment_options)
    end
  end

  # purchase!
  # - creates money transfer omiting prior authorization of payment

  def purchase!
    pay_with! do
      return false if source.blank?
      payment_gateway.gateway_purchase(total_amount.cents, source, payment_options)
    end
  end

  # There are few scenarios for PaymentSource to be authorized/captured
  # - direct_token - is usued only for Stripe PaymentGateway in Direct mode.
  #     Customer in that scenario is Stored in MPO account not Merchant, because of that
  #     we have to generate token that will allow to authorize this card in Merchant Account
  # - token - when card is saved and charged again MPO account
  # - active_merchant_card - card details send to PG

  def source
    return if payment_source.blank?
    direct_token || payment_source.to_active_merchant
  end

  def direct_token
    @direct_token ||= generate_direct_token
  end

  def generate_direct_token
    return unless payment_gateway.direct_charge?
    return unless payment_source.token && payment_source.customer_id && merchant_id

    new_direct_token = payment_gateway.create_token(
      payment_source.token,
      payment_source.customer_id,
      merchant_id,
      payment_gateway_mode
    ).try('[]', :id)

    self.direct_charge = true if new_direct_token.present?

    new_direct_token
  end

  # pay_with!
  # - capture (needs prior authorization) or purchase
  # @return [Boolean] true if paid
  def pay_with!
    return true if paid?
    return mark_as_paid! if manual_payment? || total_amount_cents.zero?
    return false unless active_merchant_payment? || valid?

    # block invokes captures or purchase method that is processed by ActiveMerchant
    # and returns ActiveMerchant response
    process_response(yield)

    paid?
  end

  def process_response(active_merchant_response)
    response = ActiveMerchant::ResponseProcessor.new(active_merchant_response, payment_gateway, merchant_account)
    update_attributes(response.payment_attributes)

    # For connected payments we are creating PaymentTransfer object
    # we should consider moving that operation to webhook as we already do for direct_payment
    create_transfer(response.transfer_id) if should_create_transfer?

    errors.add(:base, response.message)
  end

  # refund!(amount)
  # - refund method is invoked by PaymentRefundJob that first call refund! method
  #   where 3 attempts are executed. Payment#amount_to_be_refunded method determines amount
  #   that is refunded.
  # - failed refund does not block Reservation status chage

  def refund!(amount_cents)
    return false if amount_cents <= 0
    return false if refunded?
    return false if paid_at.nil? && !paid?
    return false unless active_merchant_payment?

    # This is special Braintree case, when transaction can't be refunded before
    # settlment, we use void instead
    return void! if !settled? && full_refund?

    # Refund payout takes back money from seller, break if failed.
    return false unless refund_payout!(host_refund_amount_cents(amount_cents))
    return false unless refund_service_fee!

    refund = payment_gateway.refund(amount_cents, currency, self, successful_charge)

    if refund.success?
      mark_as_refuneded!
      true
    else
      touch(:failed_at)

      if should_retry_refund?
        PaymentRefundJob.perform_later(retry_refund_at, id, amount_cents)
      else
        MarketplaceLogger.error('Refund failed', "Refund for Reservation id=#{id} failed #{refund_attempts} times, manual intervation needed.", raise: false)
      end

      false
    end
  end

  # Payment#refund_payout! moves money from host credit_card
  # to MPO so it can be later refunded to guest. This is the case
  # of all payout via BraintreeMarketplace and PayPal Adaptive Payments.
  # In case of PayPal Adaptive Payments we can alternatively ask host to grant
  # permissions to transfers from his PayPal account - future enhancement.

  def refund_payout!(amount_cents)
    return true unless transferred_to_seller?
    return true if payment_gateway.supports_refund_from_host?
    return true if refunds.mpo.successful.any?
    return false if host_cc_token.blank?

    refund = refunds.create(
      receiver: 'mpo',
      amount_cents: amount_cents,
      currency: currency,
      payment_gateway: payment_gateway,
      payment_gateway_mode: payment_gateway_mode,
      credit_card_id: credit_card.try(:id)
    )

    options = { currency: currency, customer_id: merchant_subscription_customer_id }
    response = payment_gateway.gateway_purchase(amount_cents, merchant_subscription_customer_id, options)

    if response.success?
      refund.refund_successful(response)
      true
    else
      refund.refund_failed(response)
      false
    end
  end

  # Payment#refund_service_fee!
  # When refund happens from Host account we need to first
  # refund service fee. It's the case of PayPal Express in Chained Payments.

  def refund_service_fee!
    return true unless transferred_to_seller?
    return true unless payment_gateway.supports_refund_from_host?
    return true if service_fee_refund_amount_cents.zero?
    return false if refunds.successful.any?

    refund = refunds.create(
      receiver: 'host',
      amount_cents: service_fee_refund_amount_cents,
      currency: currency,
      payment_gateway_mode: payment_gateway_mode,
      payment_gateway: payment_gateway
    )

    token = payment_transfer.payout_attempts.successful.first.response.params['transaction_id']

    response = payment_gateway.gateway.refund(service_fee_refund_amount_cents, token)

    if response.success?
      refund.refund_successful(response)
      true
    else
      service_fee_refund.refund_failed(response)
      false
    end
  end

  # Use API to get payment object stored in payment gateway
  # This objec is stadardised with our response parser
  # for example PaymentGateway::Response::Stripe::Payment
  def fetch
    return unless payment_gateway.gateway.respond_to?(:find_payment)

    payment_gateway.find_payment(external_id, merchant_account.try(:external_id))
  end

  def can_activate?
    authorized? || !payment_method.respond_to?(:payment_sources) || payment_source.try(:can_activate?)
  end

  def service_fee_refund_amount_cents
    # We only want to refund host service fee when guest cancel
    if cancelled_by_guest?
      payment_transfer.service_fee_amount_host.cents
    else
      payment_transfer.total_service_fee.cents
    end
  end

  # @return [Boolean] whether the payment has been made with the payment gateway
  #   in test mode
  def test_mode?
    return (payment_gateway || instance).test_mode? if payment_gateway_mode.blank?
    payment_gateway_mode == PaymentGateway::TEST_MODE
  end

  def settled?
    if payment_gateway.respond_to?(:payment_settled?)
      payment_gateway.payment_settled?(authorization_token)
    else
      true
    end
  end

  def payment_source_attributes=(source_attributes)
    return unless payment_method.respond_to?(:payment_sources)

    source = payment_source || payment_method.payment_sources.new
    source.attributes = source_attributes.merge(payment_method: payment_method, payer: payer)
    self.payment_source = source
  end

  alias credit_card_attributes= payment_source_attributes=
  alias credit_card= payment_source=

  def credit_card
    payment_source if payment_source_type == 'CreditCard'
  end

  def bank_account
    payment_source if payment_source_type == 'BankAccount'
  end

  def bank_account_id=(attribute_id)
    self.payment_source_id = attribute_id
    self.payment_source_type = 'BankAccount'
  end

  def paypal_account
    payment_source if payment_source_type == 'PaypalAccount'
  end

  def bank_account_id
    bank_account.try(:id)
  end

  def credit_card_id
    credit_card.try(:id)
  end

  def credit_card_id=(attribute_id)
    self.payment_source_id = attribute_id
    self.payment_source_type = 'CreditCard'
  end

  def total_additional_charges_cents
    service_additional_charges_cents + host_additional_charges_cents
  end

  def transfer_amount_cents
    result = if cancelled_by_host?
               0
             else
               subtotal_amount.cents + host_additional_charges.cents - refunds.guest.successful.sum(:amount_cents)
             end
    result -= payment_gateway_fee_cents unless mpo_pays_payment_gateway_fees?
    result
  end

  # currently MPO is not obligated to pay PG Fee only
  # when we used direct payment with Stripe Connect
  def mpo_pays_payment_gateway_fees?
    !direct_charge?
  end

  def final_service_fee_amount_host_cents
    result = service_fee_amount_host.cents

    result = 0 if cancelled_by_host? || (cancelled_by_guest? && !payable.penalty_charge_apply?)

    result
  end

  def final_service_fee_amount_guest_cents
    result = service_fee_amount_guest.cents + service_additional_charges.cents

    result = 0 if cancelled_by_host?

    result
  end

  def total_service_fee_cents
    final_service_fee_amount_host_cents + final_service_fee_amount_guest_cents
  end

  def total_amount_cents
    self[:total_amount_cents] || 0
  end

  # Alias for total_amount
  # @return [Money]
  def amount
    total_amount
  end

  def host_refund_amount_cents(amount_cents)
    amount_cents - service_fee_amount_host.cents
  end

  def full_refund?
    amount_to_be_refunded == total_amount.cents
  end

  def is_free?
    total_amount.zero?
  end

  def is_recurring?
    @recurring == true
  end

  def failed?
    !!failed_at
  end

  # @return [Boolean] whether the payment method is capturable
  def active_merchant_payment?
    payment_method.try(:capturable?)
  end

  def authorization_token
    if persisted?
      successful_billing_authorization.try(:token)
    else
      billing_authorizations.find(&:success?).try(:token)
    end
  end

  def refund_attempts
    refunds.failed.count
  end

  def should_retry_refund?
    refund_attempts < payment_gateway.max_refund_attempts
  end

  def retry_refund_at
    failed_at + (refund_attempts * 6).hours
  end

  def to_liquid
    @payment_drop ||= PaymentDrop.new(self)
  end

  private

  def payment_options
    options = { currency: currency, payment_gateway_mode: payment_gateway_mode }
    options.merge!(merchant_account.try(:custom_options) || {}) if merchant_account.try(:verified?)
    options[:customer] = payment_source.customer_id if payment_source && direct_token.blank?
    options[:mns_params] = payment_response_params if payment_response_params
    options[:application_fee] = total_service_amount_cents if merchant_account.try(:verified?)
    options[:token] = express_token if express_token
    if payment_source.respond_to?(:payment_method_nonce) && payment_source.payment_method_nonce.present?
      options[:payment_method_nonce] = payment_source.payment_method_nonce
    end

    options = payment_gateway.translate_option_keys(options)
    options.with_indifferent_access
  end

  def should_create_transfer?
    # If direct_token exists that means that we want to create aggregated
    # transfer for many charges, this happens when Stripe send us webhook.
    immediate_payout? && direct_token.blank?
  end

  def create_transfer(transfer_id = nil)
    create_payment_transfer(
      company: company,
      payments: [self],
      payment_gateway_mode: payment_gateway_mode,
      payment_gateway_id: payment_gateway_id,
      token: transfer_id
    )
  end

  # @return [Integer, nil] customer_id of Merchant Credit Card
  # user when Merchant CC is charged for Braintree Payout
  def merchant_subscription_customer_id
    merchant_account.try(:payment_subscription).try(:credit_card).try(:customer_id)
  end

  def total_service_amount_cents
    service_fee_amount_host.cents + service_fee_amount_guest.cents + service_additional_charges.cents
  end

  def host_cc_token
    merchant_account.try(:payment_subscription).try(:credit_card).try(:token)
  end

  # TODO: move this flague to Payment from BillingAuthorization
  def immediate_payout?
    successful_billing_authorization.try(:immediate_payout?) == true
  end

  def transferred_to_seller?
    payment_transfer.try(:transferred?)
  end

  def set_offline
    self.offline ||= manual_payment? || free_payment?
    true
  end

  def set_merchant_account
    return unless payment_gateway
    self.merchant_account ||= payment_gateway.merchant_account(company)
  end

  def set_payment_gateway_mode
    return unless payment_gateway
    self.payment_gateway_mode ||= payment_gateway.mode
  end

  def generate_paypal_express_link!
    response = payment_gateway.gateway.setup_authorization(total_amount.cents, payable.setup_authorization_options)
    if response.success?
      payable.restore_cached_step!
      # TODO: token should be passed to PaypalAccount
      self.express_token = response.token
      self.redirect_to_gateway = payment_gateway.gateway.redirect_url_for(express_token)
      true
    else
      errors.add(:base, response.params['Errors']['LongMessage'])
      false
    end
  end

  def require_payment_source?
    payment_gateway && payment_gateway.supports_payment_source_store? &&
      new_record? && !payment_method.manual? && !payment_method.free?
  end

  def fail!
    touch(:failed_at)
  end
end
