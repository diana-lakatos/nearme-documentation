# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway::Outgoing

  PROCESSORS = [
    Billing::Gateway::BalancedProcessor, 
    Billing::Gateway::PaypalProcessor
  ]

  delegate :payout, :to => :processor

  attr_reader :processor

  def initialize(receiver, currency)
    @sender = receiver.instance
    @receiver = receiver
    @currency = currency
    @processor = supported_processors.find { |p| p.is_supported_by?(@receiver) }.try(:new, @sender, @currency).try(:outgoing_payment, @sender, @receiver)
    self
  end

  def possible?
    supported_processors.any?
  end

  private 

  def supported_processors
    PROCESSORS.select { |processor| processor.instance_supported?(@sender) && processor.currency_supported?(@currency)  }
  end


end
