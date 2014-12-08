Spree::ShippingMethod.class_eval do
  include Spree::Scoper
  belongs_to :country

  attr_accessor :hidden, :removed

  accepts_nested_attributes_for :zones

  def calculator_attributes=(attributes)
    self.calculator ||= Spree::Calculator::Shipping::FlatRate.new()
    self.calculator.preferred_amount = attributes[:preferred_amount]
    self.calculator.preferred_currency = Spree::Config[:currency]
  end
end
