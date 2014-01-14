class Billing::Gateway::BaseProcessor
  CREDIT_CARD_PROCESSORS = [Billing::Gateway::StripeProcessor, Billing::Gateway::PaypalProcessor]

  attr_accessor :user

  def initialize(user, currency, instance)
    @user = user
    @currency = currency
    @instance = instance
  end

  def self.find_processor_class(currency)
    CREDIT_CARD_PROCESSORS.find { |potential_processor| potential_processor.payment_supported?(currency) }
  end

  # Method responsible for determining whether given currency can be processed with certain processor
  # Each subclass must define supported_currencies
  def self.payment_supported?(currency)
    raise "SUPPORTED_CURRENCIES not implemented for #{self.class.name} or does not support any currency" if !defined?(self::SUPPORTED_CURRENCIES) || self::SUPPORTED_CURRENCIES.empty? 
    self::SUPPORTED_CURRENCIES.include?(currency)
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


end
