module Billing
  # Generic billing gateway error
  Error = Class.new(::StandardError)

  # Invalid parameters provided with request
  InvalidRequestError = Class.new(Error)

  # Invalid/declined card during a charge
  class CreditCardError < Error
    attr_reader :param
    def initialize(message = nil, param = nil)
      super(message)
      @param = normalize_param_name(param)
    end

    private

    # Normalize error fields across different processors
    def normalize_param_name(param)
      case param
      when 'expire_month, expire_year', 'expire_month', 'expire_year'
        'exp_month'
      when 'type'
        'cc'
      when 'cvv2', 'type, cvv2'
        'cvc'
      else
        param
      end
    end
  end
end
