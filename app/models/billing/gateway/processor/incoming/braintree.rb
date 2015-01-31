class Billing::Gateway::Processor::Incoming::Braintree < Billing::Gateway::Processor::Incoming::Base

  def setup_api_on_initialize
    @settings = @instance.instance_payment_gateways.get_settings_for(:braintree)
    @settings.merge!({environment: @instance.test_mode? ? :sandbox : :production})
    @gateway = active_merchant_class.new(@settings)
  end

  def client_token
    @client_token ||= @gateway.generate_token
  end

  def active_merchant_class
    ActiveMerchant::Billing::BraintreeBlueGateway
  end

  def refund_identification(charge)
    charge.payment.payable.billing_authorization.token
  end

  def supported_currencies
    @settings[:supported_currency]
  end

  def support_recurring_payment?
    true
  end

  def nonce_payment?
    return true
  end
end
