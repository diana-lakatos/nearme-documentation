# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway

  attr_reader :user, :currency, :processor

  delegate :charge, :payout, :store_credit_card, :to => :processor

  def initialize(instance)
    @instance = instance
  end

  def ingoing_payment(user, currency)
    @user = user
    @currency = currency
    @processor = Billing::Gateway::BaseProcessor.find_ingoing_processor_class(@currency).try(:new, @instance).try(:ingoing_payment, @user, @currency)
    self
  end

  def outgoing_payment(sender, receiver)
    @sender = sender
    @receiver = receiver
    @processor = Billing::Gateway::BaseProcessor.find_outgoing_processor_class(@sender, @receiver).try(:new, @instance).try(:outgoing_payment, @sender, @receiver)
    self
  end

  def payment_supported?
    processor.present?
  end

end
