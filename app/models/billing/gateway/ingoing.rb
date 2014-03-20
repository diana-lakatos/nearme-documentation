# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway::Ingoing

  PROCESSORS = [
    Billing::Gateway::BalancedProcessor, 
    Billing::Gateway::StripeProcessor, 
    Billing::Gateway::PaypalProcessor
  ]

  delegate :charge, :refund, :store_credit_card, :to => :processor
  attr_reader :processor

  def initialize(user, instance, currency)
    @instance = instance
    @currency = currency
    @user = user
    @processor = (@instance.billing_gateway_for(@currency) || supported_processors.first).try(:new, @instance, @currency).try(:ingoing_payment, @user)
    self
  end

  def possible?
    supported_processors.any?
  end

  private 

  def supported_processors
    PROCESSORS.select { |processor| processor.instance_supported?(@instance) && processor.currency_supported?(@currency) }
  end

end
