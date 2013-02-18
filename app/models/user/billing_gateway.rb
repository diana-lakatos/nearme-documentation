# Encapsulate all billing  gateway related logic associated with a user
class User::BillingGateway

  # Generic billing gateway error
  BillingError = Class.new(StandardError)

  # Invalid/declined card during a charge
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

  # Wrapper object for credit card details. 
  # Encapsulates conversion and validation logic.
  #
  # Instantiate a CardDetails object from user params, for passing to the billing gateway
  # customer setup methods.
  # Use the #valid? test to tentatively determine whether or not the details could be valid.
  class CardDetails
    attr_accessor :number, :expiry_month, :expiry_year, :cvc

    # TODO: Add validations, etc.
    # include ActiveModel::Validations
    # validates_numericality_of :expiry_month, :within => 1..12
    # validates_numericality_of :expiry_year, :within => 0..99
    # ...

    # Initialize a CardDetails object encapsulating credit card details
    # 
    # details_hash - Hash of card detials
    #                :number - Credit card number string
    #                :expiry_month - Credit card expiry MM
    #                :expiry_year  - Credit card expiry YY
    #                :cvc    - Card CVC/CVV/CSC code
    def initialize(details_hash)
      self.number = details_hash[:number]
      self.expiry_month = details_hash[:expiry_month]
      self.expiry_year = details_hash[:expiry_year]
      self.cvc = details_hash[:cvc]
    end

    def parse_expiry_string(expiry_string)
    end

    def valid?
      number.present? && expiry_month.present? && expiry_year.present? && cvc.present?
    end

    def to_stripe_params
      {
        number: number,
        exp_month: expiry_month.to_i,
        exp_year: expiry_year.to_i,
        cvc: cvc.to_i
      }
    end
  end

  def initialize(user)
    @user = user
  end 

  # Return whether or not we have existing card details stored for this user.
  def has_stored_details?
    @user.stripe_id.present?
  end

  # Store the credit card against the user
  #
  # card_details - CardDetails object with credit card information
  #
  # Raises an exception on error.
  def store_card(card_details)
    if has_stored_details?
      update_card(card_details)
    else
      setup_customer(card_details)
    end
  rescue Stripe::InvalidRequestError => e
    raise InvalidRequestError, e
  rescue Stripe::StripeError => e
    raise BillingError, e
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

      # Re-raise for wrapping in custom error wrapper
      raise
    end

    charge
  rescue Stripe::CardError => e
    raise CardError, e
  rescue Stripe::StripeError => e
    raise BillingError, e
  end

  protected

  # Set up a customer and store their credit card details
  def setup_customer(card_details)
    stripe_customer = Stripe::Customer.create(
      card: card_details.to_stripe_params,
      email: @user.email
    )

    store_customer_id(stripe_customer.id)
  end

  # Store customer Id against the user
  def store_customer_id(customer_id)
    @user.stripe_id = customer_id
    @user.save!
  end

  # Update the card details associated with an existing customer
  def update_card(card_details)
    stripe_customer = Stripe::Customer.retrieve(@user.stripe_id)
    stripe_customer.card = card_details.to_stripe_params
    stripe_customer.save
  rescue Stripe::InvalidRequestError => e
    # If the error is in retrieving the customer, set up the customer instead.
    if e.param == 'id'
      return setup_customer(card_details)
    else
      raise
    end
  end

end
