class PaymentTransfer < ActiveRecord::Base
  belongs_to :company
  has_many :reservation_charges, :dependent => :nullify

  scope :pending, -> {
    where(transferred_at: nil)
  }

  scope :transferred, -> {
    where("#{table_name}.transferred_at IS NOT NULL")
  }

  after_create :assign_amounts_and_currency

  validate :validate_all_charges_in_currency

  # Amount is the amount we're transferring to the Host from payments we've
  # received for their listings.
  #
  # Note that this is the gross amount excluding the service fee that we charged
  # to the end user. The service fee is our cut of the revenue.
  monetize :amount_cents
  monetize :service_fee_amount_cents
  monetize :gross_amount_cents

  # This is the gross amount of revenue received from the charges included in
  # this payout - including the service fees recieved.
  def gross_amount_cents
    amount_cents + service_fee_amount_cents
  end

  # Whether or not we have executed the transfer to the hosts bank account.
  def transferred?
    transferred_at.present?
  end

  def mark_transferred
    touch(:transferred_at)
  end

  private

  def assign_currency
  end

  def assign_amounts_and_currency
    self.currency = reservation_charges.first.try(:currency)
    self.amount_cents = reservation_charges.sum(:subtotal_amount_cents)
    self.service_fee_amount_cents = reservation_charges.sum(
      :service_fee_amount_cents
    )
    save!(validate: false)
  end

  def validate_all_charges_in_currency
    unless reservation_charges.map(&:currency).uniq.length <= 1
      errors.add :currency, 'all paid out payments must be in the same currency'
    end
  end
end
