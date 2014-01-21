module Billing
  # Wrapper object for credit card details. 
  # Encapsulates conversion and validation logic.
  #
  # Instantiate a CreditCard object from user params, for passing to the billing gateway
  # customer setup methods.
  # Use the #valid? test to tentatively determine whether or not the details could be valid.
  class CreditCard
    include ActiveModel::Validations

    CARD_TYPES = {
      :maestro => /(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
      :dinersclub => /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
      :jcb => /^(?:2131|1800|35\d{3})\d{11}$/,
      :visa => /^4[0-9]{12}(?:[0-9]{3})?$/,
      :mastercard => /^5[1-5][0-9]{14}$/,
      :amex => /^3[47][0-9]{13}$/,
      :discover => /^6(?:011|5[0-9]{2})[0-9]{12}$/
    }

    attr_accessor :number, :expiry_month, :expiry_year, :cvc
    validates_presence_of :number, :expiry_month, :expiry_year, :cvc

    # Initialize a CardDetails object encapsulating credit card details
    #
    # details_hash - Hash of card detials
    #                :number - Credit card number string
    #                :expiry_month - Credit card expiry MM
    #                :expiry_year  - Credit card expiry YYYY
    #                :cvc    - Card CVC/CVV/CSC code
    def initialize(details_hash)
      @number = details_hash[:number]
      @expiry_month = details_hash[:expiry_month]
      @expiry_year = details_hash[:expiry_year]
      @cvc = details_hash[:cvc]
    end

    def to_stripe_params
      {
        number: number,
        exp_month: expiry_month.to_i,
        exp_year: expiry_year.to_s[2..3].to_i,
        cvc: cvc.to_s
      }
    end

    def to_paypal_params
      {
        :number => stripped_number,
        :expire_month => expiry_month.to_i,
        :expire_year => expiry_year.to_i,
        :type => card_type,
        :cvv2 => cvc.to_s
      }
    end

    def to_balanced_params
      {
        card_number: number,
        expiration_month: expiry_month.to_i,
        expiration_year: 2000 + expiry_year.to_s[2..3].to_i,
        security_code: cvc.to_s
      }
    end

    private 

    def card_type
      CARD_TYPES.keys.find { |card_type| stripped_number =~ CARD_TYPES[card_type] }.to_s
    end

    def stripped_number
      @strippped_number ||= number.squish.delete(' ')
    end
  end

end
