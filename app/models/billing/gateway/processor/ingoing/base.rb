class Billing::Gateway::Processor::Ingoing::Base < Billing::Gateway::Processor::Base
  attr_accessor :user

  def initialize(user, instance, currency)
    @client = @user = user
    @instance = instance
    @currency = currency
    setup_api_on_initialize
  end

  # Make a charge against the user
  #
  # charge_details - Hash of details describing the charge
  #                  :amount_cents - The amount in cents to charge
  #                  :reference - A reference record to assign to the charge
  #
  # Returns the Charge attempt record.
  # Test the status of the charge with the Charge#success? predicate
  def charge(charge_details)
    amount_cents, reference = charge_details[:amount_cents], charge_details[:reference]
    @charge = Charge.create(
      amount: amount_cents,
      currency: @currency,
      user_id: user.id,
      reference: reference
    )
    # Use concrete processor to perform real-life charge attempt. Processor will trigger charge_failed or charge_successful callbacks.
    process_charge(@charge.amount)
    @charge
  end

  def refund(refund_details)
    amount_cents, reference, charge_response = refund_details[:amount_cents], refund_details[:reference], refund_details[:charge_response]
    @refund = Refund.create(
      amount: amount_cents,
      currency: @currency,
      reference: reference
    )
    process_refund(amount_cents, charge_response)
    @refund
  end

  # Contains implementation for storing credit card by third party
  def store_credit_card(credit_card)
    raise NotImplementedError
  end

  # Contains implementation for processing credit card by third party
  def process_charge
    raise NotImplementedError
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

  # Callback invoked by processor when refund was successful
  def refund_successful(response)
    @refund.refund_successful(response)
  end

  # Callback invoked by processor when refund failed
  def refund_failed(response)
    @refund.refund_failed(response)
  end

  private

  def new(*args)
  end

end
