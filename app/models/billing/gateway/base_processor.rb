class Billing::Gateway::BaseProcessor
  CREDIT_CARD_PROCESSORS = [Billing::Gateway::StripeProcessor, Billing::Gateway::PaypalProcessor]
  PAYOUT_PROCESSORS = [Billing::Gateway::PaypalProcessor]

  attr_accessor :user

  def initialize(instance)
    @instance = instance
  end

  def ingoing_payment(user, currency)
    @user = user
    @currency = currency
    self
  end

  def outgoing_payment(sender, receiver)
    @sender = sender
    @receiver = receiver
    self
  end

  def self.find_ingoing_processor_class(currency)
    CREDIT_CARD_PROCESSORS.find { |potential_processor| potential_processor.ingoing_payment_supported?(currency) }
  end

  def self.find_outgoing_processor_class(sender, receiver)
    PAYOUT_PROCESSORS.find { |potential_processor| potential_processor.outgoing_payment_supported?(sender, receiver) }
  end

  # Responsible for determining whether given currency can be processed with certain processor
  def ingoing_payment_supported?(currency)
    raise "#{self.class.name} must implement ingoing_payment_supported?" 
  end

  # Responsible for determining the right processor for both parties via which transfer will be processed
  def outgoing_payment_supported?(sender, receiver)
    raise "#{self.class.name} must implement outgoing_payment_supported?" 
  end

  # Make a charge against the user
  #
  # charge_details - Hash of details describing the charge
  #                  :amount - The amount in cents to charge
  #                  :reference - A reference record to assign to the charge
  #
  # Returns the Charge attempt record.
  # Test the status of the charge with the Charge#success? predicate
  def charge(charge_details)
    amount, reference = charge_details[:amount], charge_details[:reference]
    @charge = Charge.create(
      amount: amount,
      currency: @currency,
      user_id: user.id,
      reference: reference
    )
    # Use concrete processor to perform real-life charge attempt. Processor will trigger charge_failed or charge_successful callbacks.
    process_charge(@charge.amount)
    @charge
  end

  def payout(payout_details)
    amount, reference = payout_details[:amount], payout_details[:reference]
    @payout = Payout.create(
      amount: amount.cents,
      currency: amount.currency.iso_code,
      reference: reference
    )
    process_payout(amount)
    @payout
  end

  # Contains implementation for storing credit card by third party
  def store_credit_card(credit_card)
    raise "#{self.class.name} must implement store_credit_card"
  end

  # Contains implementation for processing credit card by third party
  def process_charge
    raise "#{self.class.name} must implement process_charge"
  end

  protected

  # Callback invoked by processor when charge was successful
  def charge_successful(response)
    @charge.charge_successful(response)
  end

  # Callback invoked by processor when charge failed
  def charge_failed(response)
    @charge.charge_failed(response)
  end

  # Callback invoked by processor when payout failed
  def payout_successful(response)
    @payout.payout_successful(response)
  end

  # Callback invoked by processor when payout failed
  def payout_failed(response)
    @payout.payout_failed(response)
  end

end
