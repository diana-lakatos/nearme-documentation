class PaymentAuthorizer::PaypalExpressPaymentAuthorizer < PaymentAuthorizer

  def process!
    if @payment.express_payer_id.blank?
      setup_authorization
    else
      @response = @payment_gateway.gateway(@payment.subject).authorize(@authorizable.total_amount.cents, @options)
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
      @payment.express_checkout_redirect_url = @payment_gateway.redirect_url
      @payment.payment_method = @payment_gateway.payment_methods.first
      @payment.express_token = @payment_gateway.token
      @payment.express_checkout_redirect_url.present?
      @payment.save
    end

    def prepare_options(options)
      options.merge({
        token: @payment.express_token,
        payer_id: @payment.express_payer_id,
        currency: @payment.currency
      }).with_indifferent_access
    end
  end
