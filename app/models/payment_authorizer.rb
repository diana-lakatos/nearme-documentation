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

  def initialize(payment_gateway, payment, options={})
    @payment = payment
    @authorizable = @payment.payable
    @payment_gateway = payment_gateway
    @options = prepare_options(options)
  end

  def process!
    return false unless @authorizable.valid?

    @response = gateway_authorize(@payment.total_amount.cents, credit_card, @options)
    @response.success? ? handle_success : handle_failure
  end

  private

  def credit_card
    @credit_card ||= @payment.credit_card.to_active_merchant
  end

  def gateway_authorize(amount, cc, options)
    begin
      @payment_gateway.gateway.authorize(amount, cc, options)
    rescue => e
      OpenStruct.new({ success?: false, message: e.to_s })
    end
  end

  def handle_failure
    @payment.billing_authorizations.build(billing_authoriazation_params.merge({ success: false })) if @authorizable.respond_to?(:billing_authorizations)
    if @authorizable.instance_of?(Spree::Order)
      @authorizable.create_failed_payment!
    end
    @payment.errors.add(:base, @response.message)
    @payment.errors.add(:base, I18n.t("activemodel.errors.models.payment.attributes.base.authorization_failed"))
    false
  end

  def handle_success
    @payment.billing_authorizations.build(
      billing_authoriazation_params.merge(
        {
          success: true,
          immediate_payout: @payment_gateway.immediate_payout(@authorizable.company),
          merchant_account_id: @payment_gateway.merchant_account(@authorizable.company).try(:id)
        }
      )
    )
    if @authorizable.instance_of?(Spree::Order)
      @authorizable.create_pending_payment!
    end
    @payment.credit_card = nil unless @payment.save_credit_card?
    @payment.mark_as_authorized!
    true
  end

  def billing_authoriazation_params
    {
      token: @response.authorization,
      response: @response,
      payment_gateway: @payment_gateway,
      payment_gateway_mode: @payment_gateway.mode,
      user: @authorizable.user,
      reference: @authorizable
    }
  end

  def payment_record
    @authorizable.payments.build(amount: @authorizable.total_amount, company_id: @authorizable.company_id)
  end

  def prepare_options(options)
    options.merge({
      customer: @payment.credit_card.try(:customer_id),
      company: @authorizable.company,
      currency: @authorizable.currency,
      merchant_account: @payment_gateway.merchant_account(@authorizable.company),
      payment_method_nonce: @payment.try(:payment_method_nonce),
      service_fee_host: @authorizable.total_service_amount.cents
    }).with_indifferent_access
  end

  def platform_context
    PlatformContext.current
  end
end
