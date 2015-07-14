class PaymentGateway::BraintreePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  def self.settings
    {
      merchant_id: "",
      public_key: "",
      private_key: "",
      supported_currency: ""
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

  def supports_recurring_payment?
    true
  end

  def refund_identification(charge)
    charge.payment.payable.billing_authorization.token
  end

  def nonce_payment?
    true
  end

  def credit_card_payment?
    true
  end

  private

  def configure_braintree_class
    Braintree::Configuration.environment = settings["environment"]
    Braintree::Configuration.merchant_id = settings["merchant_id"]
    Braintree::Configuration.public_key  = settings["public_key"]
    Braintree::Configuration.private_key = settings["private_key"]
  end
end

