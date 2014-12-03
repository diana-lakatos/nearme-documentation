Spree::Order.class_eval do
  include Spree::Scoper

  belongs_to :company
  belongs_to :instance
  belongs_to :partner

  attr_accessor :card_number, :card_code, :card_expires
  scope :completed, -> { where(state: 'complete') }

  has_one :billing_authorization, as: :reference
  has_many :near_me_payments, as: :reference, class_name: '::Payment'

  def total_amount_to_charge
    monetize(self.total) + service_fee_amount_guest
  end

  def total_amount_without_fee
    monetize(self.total)
  end

  def subtotal_amount_to_charge
    monetize(self.total - self.shipment_total)
  end

  def service_fee_amount_guest
    service_fee_calculator.service_fee_guest
  end

  def service_fee_amount_host
    service_fee_calculator.service_fee_host
  end

  def service_fee_calculator
    @service_fee_calculator ||= Payment::ServiceFeeCalculator.new(subtotal_amount_to_charge, service_fee_buyer_percent, service_fee_seller_percent)
  end

  def monetize(amount)
    Money.new(amount*Money::Currency.new(self.currency).subunit_to_unit, currency)
  end

  # hackish hacky hack
  def owner
    user
  end
end
