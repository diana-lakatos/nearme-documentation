# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway::Outgoing

  delegate :payout, :to => :processor

  attr_reader :processor

  def initialize(receiver, currency)
    @receiver = receiver
    @currency = currency
    @processor = Billing::Gateway::Processor::Outgoing::ProcessorFactory.create(@receiver, @currency)
  end

  def support_automated_payout?
    Billing::Gateway::Processor::Outgoing::ProcessorFactory.support_automated_payout?(@receiver.instance, @currency)
  end

  def possible?
    processor.present?
  end

  def processor_class
    processor.class.to_s.demodulize if processor.present?
  end


end
