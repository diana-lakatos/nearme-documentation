# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway
  INGOING_PROCESSORS = [Billing::Gateway::BalancedProcessor, Billing::Gateway::StripeProcessor, Billing::Gateway::PaypalProcessor]
  OUTGOING_PROCESSORS = [Billing::Gateway::PaypalProcessor]

  attr_reader :user, :currency, :processor

  delegate :charge, :payout, :store_credit_card, :to => :processor

  def initialize(instance)
    @instance = instance
    @ingoing_processors = INGOING_PROCESSORS.select { |processor| processor.instance_supported?(instance) }
    @outgoing_processors = OUTGOING_PROCESSORS.select { |processor| processor.instance_supported?(instance) }
  end

  def ingoing_payment(user, currency)
    @user = user
    @currency = currency
    @processor = @ingoing_processors.find { |processor| processor.currency_supported?(@currency) }.try(:new, @instance).try(:ingoing_payment, @user, @currency)
    self
  end

  def outgoing_payment(sender, receiver)
    @sender = sender
    @receiver = receiver
    @processor = @outgoing_processors.find { |processor| processor.is_supported_by?(@sender) && processor.is_supported_by?(@receiver) }.try(:new, @instance).try(:outgoing_payment, @sender, @receiver)
    self
  end

  def payment_supported?
    processor.present?
  end

end
