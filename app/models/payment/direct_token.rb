# frozen_string_literal: true
class Payment
  class DirectToken

    delegate :id, to: :response, allow_nil: true

    def initialize(payment)
      @payment = payment
      @payment_gateway = @payment.payment_gateway
      @payment_source = @payment.payment_source
      @merchant_id = @payment.merchant_id
      @customer_id = @payment_source.customer_id
    end

    def direct_charge?
      id.present?
    end

    def response
      return unless @payment_gateway.direct_charge?
      return unless @customer_id
      return unless @merchant_id

      @response ||= @payment_gateway.create_token(@customer_id, @merchant_id, options)
    end

    def options
      case @payment_source
      when BankAccount then { bank_account: @payment_source.to_active_merchant }
      when CreditCard then { card: @payment_source.to_active_merchant }
      else {}
      end
    end
  end
end
