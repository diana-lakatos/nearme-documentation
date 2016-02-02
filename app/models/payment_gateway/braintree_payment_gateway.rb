class PaymentGateway::BraintreePaymentGateway < PaymentGateway
  include PaymentGateway::ActiveMerchantGateway

  MAX_REFUND_ATTEMPTS = 10

  supported :any_currency, :company_onboarding, :recurring_payment, :nonce_payment,
    :credit_card_payment, :partial_refunds

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

  def gateway_refund(amount, token, options)
    configure_braintree_class
    transaction = Braintree::Transaction.find(token)
    if transaction.status == 'submitted_for_settlement' && (transaction.amount * 100).to_i == amount
      gateway_void(token)
    else
      super
    end
  end

  def max_refund_attempts
    MAX_REFUND_ATTEMPTS
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
    charge.payment.authorization_token
  end

  private

  def configure_braintree_class
    Braintree::Configuration.environment = settings["environment"]
    Braintree::Configuration.merchant_id = settings["merchant_id"]
    Braintree::Configuration.public_key  = settings["public_key"]
    Braintree::Configuration.private_key = settings["private_key"]
  end
end

