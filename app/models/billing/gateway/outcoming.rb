# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway::Outcoming

  PROCESSORS = [
    Billing::Gateway::Processor::Outcoming::Balanced, 
    Billing::Gateway::Processor::Outcoming::Paypal
  ]

  delegate :payout, :to => :processor

  attr_reader :processor

  def initialize(receiver, currency)
    @sender = receiver.instance
    @receiver = receiver
    @currency = currency
    @processor = supported_processors.find { |p| p.is_supported_by?(@receiver) }.try(:new, @receiver, @currency)
  end

  def support_automated_payout?
    supported_processors.any?
  end

  def possible?
    processor.present?
  end

  def processor_class
    processor.class.to_s.demodulize
  end

  private 

  def supported_processors
    PROCESSORS.select { |processor| processor.instance_supported?(@sender) && processor.currency_supported?(@currency)  }
  end


end
