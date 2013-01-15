# Encapsulate all billing  gateway related logic associated with a user
class User::BillingGateway

  # Generic billing gateway error
  BillingError = Class.new(StandardError)

  # Invalid card during a charge
  CardError = Class.new(BillingError)

  # Invalid parameters provided with request
  InvalidRequestError = Class.new(BillingError)

  # User helper to add associations on the user data object
  module UserHelper
    extend ActiveSupport::Concern

    included do
      has_many :charges, :foreign_key => :user_id, :dependent => :destroy
    end

    def billing_gateway
      @billing_gateway ||= User::BillingGateway.new(self)
    end
  end

  def initialize(user)
    @user = user
  end 

  # Store the credit card against the user
  #
  # card_details - Hash of credit card information
  #                :number - Credit card number string
  #                :expiry_month - Credit card expiry MM
  #                :expiry_year  - Credit card expiry YY
  #                :cvc    - Card CVC/CVV/CSC code
  #
  # Raises an exception on error.
  def store_card(card_details)
    if @user.stripe_id.present?
      update_card(card_details)
    else
      setup_customer(card_details)
    end
  rescue Stripe::InvalidRequestError
    raise InvalidRequestError, $!
  rescue Stripe::StripeError
    raise BillingError, $!
  end

  # Make a charge against the user
  #
  # charge_details - Hash of details describing the charge
  #                  :amount - The amount in cents to charge
  #                  :currency - Three character currency code
  #                  :reference - A reference record to assign to the charge
  #
  # Returns the Charge attempt record. 
  # Test the status of the charge with the Charge#success? predicate
  def charge(charge_details)
    amount, currency, reference = charge_details[:amount], charge_details[:currency], charge_details[:reference]

    # Create charge record
    charge = Charge.create(
      amount: amount,
      currency: currency,
      user_id: @user.id,
      reference: reference
    )

    begin
      stripe_charge = Stripe::Charge.create(
        amount: amount,
        currency: currency,
        customer: @user.stripe_id
      )

      charge.charge_successful(stripe_charge)
    rescue
      charge.charge_failed($!)

      # Re-raise for wrapping in customer error wrapper
      raise
    end

    charge
  rescue Stripe::CardError
    raise CardError, $!
  rescue Stripe::StripeError
    raise BillingError, $!
  end

  protected

  # Set up a customer and store their credit card details
  def setup_customer(card_details)
    stripe_customer = Stripe::Customer.create(
      card: {
        number: card_details[:number],
        exp_month: card_details[:expiry_month],
        exp_year: card_details[:expiry_year],
        cvc: card_details[:cvc]
      },
      email: @user.email
    )

    @user.stripe_id = stripe_customer.id
    @user.save!
  end

  # Update the card details associated with an existing customer
  def update_card(card_details)
    stripe_customer = Stripe::Customer.retrieve(@user.stripe_id)
    stripe_customer.card = {
      number: card_details[:number],
      exp_month: card_details[:expiry_month],
      exp_year: card_details[:expiry_year],
      cvc: card_details[:cvc]
    }
    stripe_customer.save
  rescue Stripe::InvalidRequestError
    # If the error is in retrieving the customer, set up the customer instead.
    if $!.param == 'id'
      return setup_customer(card_details)
    else
      raise
    end
  end

end