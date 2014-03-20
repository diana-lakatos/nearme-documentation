# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway

  attr_reader :processor

  delegate :charge, :payout, :refund, :store_credit_card, :to => :processor

  def initialize(instance, currency)
    @instance = instance
    @currency = currency
  end

  def ingoing_payment(user)
    @gateway = Billing::Gateway::Ingoing.new(user, @instance, @currency)
    self
  end

  def outgoing_payment(receiver)
    @gateway = Billing::Gateway::Outgoing.new(receiver, @currency)
    self
  end

  def processor_class
    "#{processor.try(:class)}".demodulize.gsub('Processor', '')
  end

  def processor 
    @gateway.processor
  end

  def payment_supported?
    @gateway.possible?
  end

  def payout_possible?
    @gateway.possible?
  end
  
end
