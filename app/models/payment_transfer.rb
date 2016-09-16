class PaymentTransfer < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  attr_encrypted :token, key: DesksnearMe::Application.config.secret_token

  FREQUENCIES = %w(monthly fortnightly weekly semiweekly daily manually)
  DEFAULT_FREQUENCY = "fortnightly"

  belongs_to :company
  belongs_to :instance
  belongs_to :partner
  belongs_to :payment_gateway

  has_many :payments, :dependent => :nullify

  has_many :payout_attempts,
    -> { order 'created_at ASC' },
    :class_name => 'Payout',
    :as => :reference,
    :dependent => :nullify

  after_create :assign_amounts_and_currency
  after_create :payout

  scope :pending, -> {
    where(transferred_at: nil)
  }

  scope :transferred, -> {
    where("#{table_name}.transferred_at IS NOT NULL")
  }

  scope :last_x_days, lambda { |days_in_past|
    where("DATE(#{table_name}.created_at) >= ? ", days_in_past.days.ago)
  }
  scope :with_token, -> (not_encrypted_token) { where(encrypted_token: PaymentTransfer.encrypt_token(not_encrypted_token, key: DesksnearMe::Application.config.secret_token)) }

  validate :validate_all_charges_in_currency

  # Amount is the amount we're transferring to the Host from payments we've
  # received for their listings.
  #
  # Note that this is the gross amount excluding the service fee that we charged
  # to the end user. The service fee is our cut of the revenue.

  monetize :amount_cents, with_model_currency: :currency
  monetize :service_fee_amount_guest_cents, with_model_currency: :currency
  monetize :service_fee_amount_host_cents, with_model_currency: :currency

  # This is the gross amount of revenue received from the charges included in
  # this payout - including the service fees recieved.
  def gross_amount_cents
    amount_cents + service_fee_amount_guest_cents + service_fee_amount_host_cents
  end

  def gross_amount
    Money.new(gross_amount_cents, currency)
  end

  # Whether or not we have executed the transfer to the hosts bank account.
  def transferred?
    transferred_at.present?
  end

  def mark_transferred
    touch(:transferred_at)
  end

  def mark_as_failed
    touch(:failed_at)
  end

  def company_including_deleted
    Company.with_deleted.find(company_id)
  end

  # Attempt to payout through the billing gateway
  def payout
    return if !payout_gateway.present?
    return if transferred?
    return if amount <= 0
    return if payout_attempts.any?

    # Generates a ChargeAttempt with this record as the reference.
    payout = payout_gateway.payout(
      company,
      amount: amount,
      reference: self,
      payment_gateway_mode: payment_gateway_mode
    )

    if payout.success
      touch(:transferred_at)
    end
  end

  def pending?
    payout_attempts.last && payout_attempts.last.pending?
  end

  def failed?
    failed_at.present?
  end

  def fail!
    self.update_column(:transferred_at, nil) if self.payout_attempts.reload.successful.count.zero? && persisted?
  end

  def success!
    if (payout = self.payout_attempts.reload.successful.first).present? && persisted?
      mark_transferred
    end
  end

  def payout_processor
    payout_gateway
  end

  def possible_automated_payout_not_supported?
    # true if instance makes it possible to make automated payout for given currency, but company does not support it
    # false if either company can process this payment transfer automatically or instance does not support it
    payout_gateway.try(:supports_payout?) && company.merchant_accounts.where(payment_gateway: payout_gateway).count.zero?
  end

  def total_service_fee_cents
    return self.service_fee_amount_host_cents + self.service_fee_amount_guest_cents
  end

  def total_service_fee
    Money.new(total_service_fee_cents, currency)
  end


  private

  def assign_amounts_and_currency
    self.currency = payments.first.try(:currency)
    self.service_fee_amount_host_cents = payments.inject(0) { |sum, rc| sum += rc.final_service_fee_amount_host_cents }
    self.amount_cents = payments.all.inject(0) { |sum, rc| sum += rc.subtotal_amount_cents_after_refund } - self.service_fee_amount_host_cents
    self.service_fee_amount_guest_cents = payments.inject(0) { |sum, rc| sum += rc.final_service_fee_amount_guest_cents }
    self.save!
  end

  def validate_all_charges_in_currency
    unless payments.map(&:currency).uniq.length <= 1
      errors.add :currency, 'all paid out payments must be in the same currency'
    end
  end

  def payout_gateway
    if @payout_gateway.nil?
      @payout_gateway = payment_gateway || instance.payout_gateway(company.iso_country_code, currency)
    end
    @payout_gateway
  end
end
