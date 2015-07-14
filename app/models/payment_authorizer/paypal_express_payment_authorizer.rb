class PaymentAuthorizer::PaypalExpressPaymentAuthorizer < PaymentAuthorizer

  def process!
    if @authorizable.express_token.blank?
      setup_authorization
    else
      @response = @payment_gateway.gateway(@authorizable.merchant_payer_id).authorize(@authorizable.total_amount_cents, @options)
      @response.success? ? handle_success : handle_failure
    end
  end

  private

    def setup_authorization
      @payment_gateway.process_express_checkout(@authorizable, {
        return_url: return_express_checkout_listing_reservations_url(@authorizable.listing, host: platform_context.decorate.host),
        cancel_return_url: cancel_express_checkout_listing_reservations_url(@authorizable.listing, host: platform_context.decorate.host)
      })
      @authorizable.payment_method = Reservation::PAYMENT_METHODS[:express]
      @authorizable.express_checkout_redirect_url = @payment_gateway.redirect_url
      @authorizable.express_token = @payment_gateway.token

      @authorizable.express_checkout_redirect_url.present?
    end

    def prepare_options(options)
      options.merge({
        token: @authorizable.express_token,
        payer_id: @authorizable.express_payer_id
      }).with_indifferent_access
    end
  end