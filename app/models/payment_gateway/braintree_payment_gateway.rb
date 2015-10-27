class PaymentGateway::BraintreePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  supported :any_currency, :company_onboarding, :recurring_payment, :nonce_payment,
    :credit_card_payment

  def self.settings
    {
      merchant_id: "",
      public_key: "",
      private_key: "",
    }
  end

  def self.active_merchant_class
    ActiveMerchant::Billing::BraintreeBlueGateway
  end

  def settings
    super.merge({environment: test_mode? ? :sandbox : :production})
  end

  def client_token
    configure_braintree_class
    @client_token ||= Braintree::ClientToken.generate
  end

  def supported_currencies
    @supported_currencies ||= Array.wrap(settings[:supported_currency])
  end

  def refund_identification(charge)
    charge.payment.payable.billing_authorization.token
  end

  private

  def configure_braintree_class
    Braintree::Configuration.environment = settings["environment"]
    Braintree::Configuration.merchant_id = settings["merchant_id"]
    Braintree::Configuration.public_key  = settings["public_key"]
    Braintree::Configuration.private_key = settings["private_key"]
  end
end

