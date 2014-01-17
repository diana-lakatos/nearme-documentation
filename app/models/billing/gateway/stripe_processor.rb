class Billing::Gateway::StripeProcessor < Billing::Gateway::BaseProcessor
  SUPPORTED_CURRENCIES = ['USD']

  def initialize(*args)
    super(*args)
    @api_key = @instance.custom_stripe_api_key
  end

  def store_credit_card(credit_card)
    if user.stripe_id.present?
      update_credit_card(credit_card)
    else
      setup_customer_with_credit_card(credit_card)
    end
  rescue Stripe::InvalidRequestError => e
    raise Billing::InvalidRequestError, e
  rescue Stripe::CardError => e
    message = e.message.gsub(/\(Status .*\)/, '')
    raise Billing::CreditCardError.new(message, e.param)
  rescue Stripe::StripeError => e
    raise Billing::Error, e
  end

  def process_charge(amount)
    begin
      stripe_charge = Stripe::Charge.create({ amount: amount, currency: @currency, customer: user.stripe_id }, @api_key)
      charge_successful(stripe_charge)
    rescue
      charge_failed($!)
      # Re-raise for wrapping in custom error wrapper
      raise
    end
  rescue Stripe::CardError => e
    raise Billing::CreditCardError, e
  rescue Stripe::StripeError => e
    raise Billing::Error, e
  end

  private

  # Set up a customer and store their credit card details
  def setup_customer_with_credit_card(credit_card)
    stripe_customer = Stripe::Customer.create(
      {
        card: credit_card.to_stripe_params,
        email: user.email
      }, @api_key
    )

    # Store customer Id against the user
    user.stripe_id = stripe_customer.id
    user.save!
  end

  # Update the card details associated with an existing customer
  def update_credit_card(credit_card)
    stripe_customer = Stripe::Customer.retrieve(user.stripe_id, @api_key)
    stripe_customer.card = credit_card.to_stripe_params
    stripe_customer.save
  rescue Stripe::InvalidRequestError => e
    # If the error is in retrieving the customer, set up the customer instead.
    if e.param == 'id'
      return setup_customer_with_credit_card(credit_card)
    else
      raise
    end
  end

end
