# frozen_string_literal: true
class PaymentTransfer < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  attr_encrypted :token, key: DesksnearMe::Application.config.secret_token

  FREQUENCIES = %w(monthly fortnightly weekly semiweekly daily manually).freeze
  DEFAULT_FREQUENCY = 'fortnightly'

  belongs_to :company
  belongs_to :instance
  belongs_to :partner
  belongs_to :payment_gateway
  belongs_to :merchant_account

  has_many :payments, dependent: :nullify

  has_many :payout_attempts,
           -> { order 'created_at ASC' },
           class_name: 'Payout',
           as: :reference,
           dependent: :nullify

  after_create :assign_amounts_and_currency
  after_create :payout

  scope :pending, lambda {
    where(transferred_at: nil)
  }

  scope :transferred, lambda {
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
  monetize :payment_gateway_fee_cents, with_model_currency: :currency
  monetize :service_fee_amount_guest_cents, with_model_currency: :currency
  monetize :service_fee_amount_host_cents, with_model_currency: :currency

  def gross_amount_cents
    amount_cents + service_fee_amount_host_cents + payment_gateway_fee_cents
  end

  def gross_amount
    Money.new(gross_amount_cents, currency)
  end

  def total_service_fee_cents
    service_fee_amount_host_cents + service_fee_amount_guest_cents
  end

  def total_service_fee
    Money.new(total_service_fee_cents, currency)
  end

  # Whether or not we have executed the transfer to the hosts bank account.
  def transferred?
    transferred_at.present?
  end
  alias paid? transferred?

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
    return unless payout_gateway.present?
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

    touch(:transferred_at) if payout.success
  end

  def pending?
    payout_attempts.last.present? && payout_attempts.last.pending?
  end

  def failed?
    failed_at.present?
  end

  def fail!
    mark_as_failed
    update_column(:transferred_at, nil) if payout_attempts.reload.successful.count.zero? && persisted?
  end

  def success!
    if (payout = payout_attempts.reload.successful.first).present? && persisted?
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

  def to_liquid
    @payment_transfer_drop ||= PaymentTransferDrop.new(self)
  end

  private

  def assign_amounts_and_currency
    self.currency = payments.first.try(:currency)
    self.payment_gateway_fee_cents = payments.inject(0) { |sum, rc| sum += rc.payment_gateway_fee_cents }
    self.service_fee_amount_host_cents = payments.inject(0) { |sum, rc| sum += rc.final_service_fee_amount_host_cents }
    self.amount_cents = payments.all.inject(0) { |sum, rc| sum += rc.subtotal_amount_cents_after_refund } - service_fee_amount_host_cents - payment_gateway_fee_cents
    self.service_fee_amount_guest_cents = payments.inject(0) { |sum, rc| sum += rc.final_service_fee_amount_guest_cents }
    save!
  end

  def validate_all_charges_in_currency
    errors.add :currency, 'all paid out payments must be in the same currency' unless payments.map(&:currency).uniq.length <= 1
  end

  def payout_gateway
    @payout_gateway = payment_gateway || instance.payout_gateway(company.iso_country_code, currency) if @payout_gateway.nil?
    @payout_gateway
  end
end
