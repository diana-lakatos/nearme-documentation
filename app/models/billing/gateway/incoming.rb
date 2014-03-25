# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway::Incoming


  delegate :charge, :refund, :store_credit_card, :to => :processor
  attr_reader :processor

  def initialize(user, instance, currency)
    @processor = Billing::Gateway::Processor::Incoming::ProcessorFactory.create(user, instance, currency)
  end

  def possible?
    processor.present?
  end

end
