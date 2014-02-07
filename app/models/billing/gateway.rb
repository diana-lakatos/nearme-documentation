# Encapsulate all billing  gateway related logic associated with a user
class Billing::Gateway
  INGOING_PROCESSORS = [Billing::Gateway::BalancedProcessor, Billing::Gateway::StripeProcessor, Billing::Gateway::PaypalProcessor]
  OUTGOING_PROCESSORS = [Billing::Gateway::PaypalProcessor, Billing::Gateway::BalancedProcessor]

  attr_reader :user, :currency, :processor, :outgoing_processors

  delegate :charge, :payout, :refund, :store_credit_card, :to => :processor

  def initialize(instance, currency)
    @instance = instance
    @currency = currency
    @ingoing_processors = INGOING_PROCESSORS.select { |processor| processor.instance_supported?(instance) && processor.currency_supported?(currency) }
    @outgoing_processors = OUTGOING_PROCESSORS.select { |processor| processor.instance_supported?(instance) && processor.currency_supported?(currency) }
  end

  def ingoing_payment(user)
    @user = user
    @processor = (@instance.billing_gateway_for(@currency) || @ingoing_processors.first).try(:new, @instance, @currency).try(:ingoing_payment, @user)
    self
  end

  def outgoing_payment(receiver)
    @sender = receiver.instance
    @receiver = receiver
    @processor = initialize_outgoing_processor(outgoing_processor_class)
    self
  end

  def payment_supported?
    processor.present?
  end

  def payout_possible?
    outgoing_processors.any?
  end
  
  private

  def outgoing_processor_class
    outgoing_processors.find { |processor| processor.is_supported_by?(@receiver) }
  end

  def initialize_outgoing_processor(outgoing_processor_class)
    return nil if outgoing_processor_class.nil?
    outgoing_processor_class.new(@instance, @currency).outgoing_payment(@sender, @receiver)
  end

end
