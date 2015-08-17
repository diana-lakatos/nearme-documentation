class PaymentAuthorizer::PaypalPaymentAuthorizer < PaymentAuthorizer
  private
    def gateway_authorize
      response = @payment_gateway.gateway(@authorizable.merchant_subject).
        authorize(
          @authorizable.total_amount_cents,
          credit_card_or_token,
          @options
        )
    end
  end