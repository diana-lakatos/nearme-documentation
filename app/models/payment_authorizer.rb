# By default PaymentAuthorizer is called from PaymentGateway instance authorize method.
# To achive custom behaviour it's possible to overide it within specific PaymentGateway subclass i.e.
# PaymentGateway::ManualPaymentGateway that invokes PaymentAuthorizer subclass
# PaymentAuthorizer::ManualPaymentAuthorizer. This way we can customize authorization
# behaviour for every payment gateway without many conditional statements.

# Failed validation of CC sends error message that is then displayed as flash message.

# Succesful authorization creates successful billing authorization object assigned to Reservation or
# Spree::Order, token saved within it is then used to capture payment.

# Failed authorization creates failed billing authorization assigned to Transactable or Spree::Order

class PaymentAuthorizer
  include Rails.application.routes.url_helpers

  # authorizable argument in initialize method can be instance of
  # Spree::Order, ReservationRequest or Reservation class
  # depending from where authorize method is called.

  def initialize(payment_gateway, authorizable, options={})
    @authorizable = authorizable
    @payment_gateway = payment_gateway
    @options = prepare_options(options)
  end

  def process!
    return false unless @authorizable.valid?

    @response = gateway_authorize
    @response.success? ? handle_success : handle_failure
  end

  private

  def gateway_authorize
    @payment_gateway.gateway.authorize(@authorizable.total_amount.cents, credit_card_or_token, @options)
  end

  def handle_failure
    @authorizable.errors.add(:cc, @response.message)
    @authorizable.billing_authorizations.create(billing_authoriazation_params.merge({ success: false })) if @authorizable.respond_to?(:billing_authorizations)
    @authorizable.create_failed_payment! if @authorizable.instance_of?(Spree::Order)

    false
  end

  def handle_success
    @authorizable.create_billing_authorization(
      billing_authoriazation_params.merge(
        {
          success: true,
          immediate_payout: @payment_gateway.immediate_payout(@authorizable.company),
          merchant_account_id: @payment_gateway.merchant_account(@authorizable.company).try(:id)
        }
      )
    )
    @authorizable.create_pending_payment! if @authorizable.instance_of?(Spree::Order)
    @response.authorization
  end

  def billing_authoriazation_params
    {
      token: @response.authorization,
      response: @response,
      payment_gateway: @payment_gateway,
      payment_gateway_mode: @payment_gateway.mode,
      user_id: @authorizable.user.id,
    }
  end

  def credit_card_or_token
    @authorizable.credit_card.try(:token) || @authorizable.credit_card
  end

  def payment_record
    @authorizable.payments.build(amount: @authorizable.total_amount, company_id: @authorizable.company_id)
  end

  def prepare_options(options)
    options.merge({
      company: @authorizable.company,
      currency: @authorizable.currency,
      merchant_account: @payment_gateway.merchant_account(@authorizable.company),
      payment_method_nonce: @authorizable.try(:payment_method_nonce),
      service_fee_host: @authorizable.total_service_amount.cents
    }).with_indifferent_access
  end

  def platform_context
    PlatformContext.current
  end
end
