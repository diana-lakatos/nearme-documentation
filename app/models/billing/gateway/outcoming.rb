# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway::Outcoming

  delegate :payout, :to => :processor

  attr_reader :processor

  def initialize(receiver, currency)
    @receiver = receiver
    @currency = currency
    @processor = Billing::Gateway::Processor::Outcoming::ProcessorFactory.create(@receiver, @currency)
  end

  def support_automated_payout?
    Billing::Gateway::Processor::Outcoming::ProcessorFactory.support_automated_payout?(@receiver, @currency)
  end

  def possible?
    processor.present?
  end

  def processor_class
    processor.class.to_s.demodulize
  end


end
