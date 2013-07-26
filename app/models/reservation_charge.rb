class ReservationCharge < ActiveRecord::Base
  acts_as_paranoid

  # === Associations
  belongs_to :reservation
  has_many :charge_attempts,
    :class_name => 'Charge',
    :as => :reference,
    :dependent => :nullify

  # === Scopes
  # These payments have been attempted but failed during the charge attempt.
  # We can inspect the charge_attempts to see what the failure reason was
  # from the gateway response.
  scope :needs_payment_capture, -> {
    where(paid_at: nil).where("#{table_name}.failed_at IS NOT NULL")
  }

  scope :paid, -> {
    where("#{table_name}.paid_at IS NOT NULL")
  }

  scope :last_x_days, lambda { |days_in_past|
    where('DATE(reservation_charges.created_at) >= ? ', days_in_past.days.ago)
  }

  scope :needs_payment_transfer, -> {
    paid.where(payment_transfer_id: nil)
  }

  scope :needs_payment_transfer, -> {
    paid.where(payment_transfer_id: nil)
  }

  scope :total_by_currency, -> {
    paid.joins(:reservation).
      group('reservations.currency').
      select('
        reservations.currency,
        SUM(
          reservation_charges.subtotal_amount_cents
          + reservation_charges.service_fee_amount_cents
        )
      ')
  }

  # === Callbacks
  before_validation :assign_currency
  after_create :capture

  validates :currency, presence: true

  # === Helpers
  monetize :subtotal_amount_cents
  monetize :service_fee_amount_cents
  monetize :total_amount_cents

  def total_amount_cents
    subtotal_amount_cents + service_fee_amount_cents
  end

  def amount
    total_amount
  end

  # Attempt to capture the payment through the billing gateway
  def capture
    return if paid?

    # Generates a ChargeAttempt with this record as the reference.
    billing_gateway.charge(
      amount: total_amount_cents,
      currency: currency,
      reference: self
    )

    touch(:paid_at)
  rescue User::BillingGateway::CardError
    # Needs to be retried at a later time...
    touch(:failed_at)
  end

  def paid?
    paid_at.present?
  end

  private

  def billing_gateway
    reservation.owner.billing_gateway
  end

  def assign_currency
    self.currency ||= reservation.currency
  end
end
