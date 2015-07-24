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
    @client_token ||= gateway.generate_token
  end

  def supported_currencies
    @supported_currencies ||= Array.wrap(settings[:supported_currency])
  end

  def support_recurring_payment?
    true
  end

  def refund_identification(charge)
    charge.payment.payable.billing_authorization.token
  end

  def nonce_payment?
    false #true
  end
end

