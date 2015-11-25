class PaymentAuthorizer::PaypalExpressPaymentAuthorizer < PaymentAuthorizer

  def process!
    if @authorizable.express_payer_id.blank?
      setup_authorization
    else
      @response = @payment_gateway.gateway(@authorizable.merchant_subject).authorize(@authorizable.total_amount_cents, @options)
      @response.success? ? handle_success : handle_failure
    end
  end

  private

    def setup_authorization
      @payment_gateway.process_express_checkout(@authorizable, {
        return_url: @authorizable.express_return_url,
        cancel_return_url: @authorizable.express_cancel_return_url,
        ip: "127.0.0.1"
      })
      @authorizable.express_checkout_redirect_url = @payment_gateway.redirect_url
      @authorizable.payment_method = @payment_gateway.payment_methods.first
      @authorizable.express_token = @payment_gateway.token
      @authorizable.express_checkout_redirect_url.present?
    end

    def prepare_options(options)
      options.merge({
        token: @authorizable.express_token,
        payer_id: @authorizable.express_payer_id,
        currency: @authorizable.currency
      }).with_indifferent_access
    end
  end
