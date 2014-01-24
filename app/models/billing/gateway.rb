# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway
  INGOING_PROCESSORS = [Billing::Gateway::BalancedProcessor, Billing::Gateway::StripeProcessor, Billing::Gateway::PaypalProcessor]
  OUTGOING_PROCESSORS = [Billing::Gateway::PaypalProcessor, Billing::Gateway::BalancedProcessor]

  attr_reader :user, :currency, :processor, :outgoing_processors

  delegate :charge, :payout, :store_credit_card, :to => :processor

  def initialize(instance, currency)
    @instance = instance
    @currency = currency
    @ingoing_processors = INGOING_PROCESSORS.select { |processor| processor.instance_supported?(instance) && processor.currency_supported?(currency) }
    @outgoing_processors = OUTGOING_PROCESSORS.select { |processor| processor.instance_supported?(instance) && processor.currency_supported?(currency) }
  end

  def ingoing_payment(user)
    @user = user
    @processor = @ingoing_processors.first.try(:new, @instance, @currency).try(:ingoing_payment, @user)
    self
  end

  def outgoing_payment(receiver)
    @sender = receiver.instance
    @receiver = receiver
    @processor = outgoing_processors.find { |processor| processor.is_supported_by?(@receiver) }.try(:new, @instance, @currency).try(:outgoing_payment, @sender, @receiver)
    self
  end

  def payment_supported?
    processor.present?
  end

  def payout_possible?
    outgoing_processors.any?
  end

end
