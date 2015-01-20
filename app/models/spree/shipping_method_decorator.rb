Spree::ShippingMethod.class_eval do
  include Spree::Scoper
  belongs_to :country

  belongs_to :order

  attr_accessor :hidden, :removed

  accepts_nested_attributes_for :zones

  validates :processing_time, presence: true
  validates :processing_time, numericality: { greater_than_or_equal_to: 0 }

  before_validation do
    self.processing_time = self.processing_time.to_i
  end

  def calculator_attributes=(attributes)
    self.calculator ||= Spree::Calculator::Shipping::FlatRate.new()
    self.calculator.preferred_amount = attributes[:preferred_amount]
    self.calculator.preferred_currency = Spree::Config[:currency]
  end
end
