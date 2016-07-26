# By default PaymentAuthorizer is called from PaymentGateway instance authorize method.
# To achive custom behaviour it's possible to overide it within specific PaymentGateway subclass i.e.
# PaymentGateway::ManualPaymentGateway that invokes PaymentAuthorizer subclass
# PaymentAuthorizer::ManualPaymentAuthorizer. This way we can customize authorization
# behaviour for every payment gateway without many conditional statements.

# Failed validation of CC sends error message that is then displayed as flash message.

# Succesful authorization creates successful billing authorization object assigned to Reservation or
# Order, token saved within it is then used to capture payment.

# Failed authorization creates failed billing authorization assigned to Transactable or Order

class PaymentAuthorizer
  include Rails.application.routes.url_helpers

  # authorizable argument in initialize method can be instance of
  # Reservation Purchase RecurringBooking class
  # depending from where authorize method is called.

  def initialize(payment_gateway, payment, options={})
    @payment = payment
    @authorizable = @payment.payable
    @payment_gateway = payment_gateway
    @options = prepare_options(options)
  end

  def process!
    return false unless @authorizable.valid?
    @response = @payment_gateway.gateway_authorize(@payment.total_amount.cents, credit_card, @options)
    @response.success? ? handle_success : handle_failure
  end

  private

  def credit_card
    @credit_card ||= @payment.credit_card.try(:to_active_merchant)
  end

  def handle_failure
    @payment.billing_authorizations.build(billing_authoriazation_params.merge({ success: false })) if @authorizable.respond_to?(:billing_authorizations)
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
          merchant_account_id: merchant_account.try(:id)
        }
      )
    )
    @payment.merchant_account_id = merchant_account.try(:id)
    @payment.credit_card = nil unless @payment.save_credit_card?
    @payment.mark_as_authorized!
    true
  end

  def merchant_account
    @payment_gateway.merchant_account(@authorizable.company)
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
      company: @payment.company,
      currency: @payment.currency,
      merchant_account: merchant_account,
      payment_method_nonce: @payment.try(:payment_method_nonce),
      service_fee_host: @payment.total_service_amount_cents
    }).with_indifferent_access
  end

  def platform_context
    PlatformContext.current
  end
end
