class PaymentTransfer < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  belongs_to :company
  has_many :reservation_charges, :dependent => :nullify

  has_many :payout_attemps,
    :class_name => 'Payout',
    :as => :reference,
    :dependent => :nullify

  after_validation :assign_amounts_and_currency
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


  validate :validate_all_charges_in_currency

  # Amount is the amount we're transferring to the Host from payments we've
  # received for their listings.
  #
  # Note that this is the gross amount excluding the service fee that we charged
  # to the end user. The service fee is our cut of the revenue.
  monetize :amount_cents
  monetize :service_fee_amount_guest_cents
  monetize :service_fee_amount_host_cents
  monetize :gross_amount_cents

  # This is the gross amount of revenue received from the charges included in
  # this payout - including the service fees recieved.
  def gross_amount_cents
    amount_cents + service_fee_amount_guest_cents + service_fee_amount_host_cents
  end

  # Whether or not we have executed the transfer to the hosts bank account.
  def transferred?
    transferred_at.present?
  end

  def mark_transferred
    touch(:transferred_at)
  end

  def company_including_deleted
    Company.with_deleted.find(company_id)
  end

   # Attempt to payout through the billing gateway
  def payout
    return if !billing_gateway.payment_supported?
    return if transferred?

    # Generates a ChargeAttempt with this record as the reference.
    payout = billing_gateway.payout(
      amount: amount,
      reference: self
    )

    if payout.success
      touch(:transferred_at)
    end
  end

  private

  def assign_amounts_and_currency
    self.currency = reservation_charges.first.try(:currency)
    self.service_fee_amount_host_cents = reservation_charges.sum(
      :service_fee_amount_host_cents
    )
    self.amount_cents = reservation_charges.sum(:subtotal_amount_cents) - self.service_fee_amount_host_cents
    self.service_fee_amount_guest_cents = reservation_charges.sum(
      :service_fee_amount_guest_cents
    )
  end

  def validate_all_charges_in_currency
    unless reservation_charges.map(&:currency).uniq.length <= 1
      errors.add :currency, 'all paid out payments must be in the same currency'
    end
  end

  def billing_gateway
    @billing_gateway ||= Billing::Gateway.new(company.instance).outgoing_payment(company.instance, company, currency)
  end
end
