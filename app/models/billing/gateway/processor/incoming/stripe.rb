class Billing::Gateway::Processor::Incoming::Stripe < Billing::Gateway::Processor::Incoming::Base
  def setup_api_on_initialize
    settings = @instance.instance_payment_gateways.get_settings_for(:stripe)
    @gateway = active_merchant_class.new(settings)
  end

  def active_merchant_class
    ActiveMerchant::Billing::StripeGateway
  end

  def refund_identification(charge_response)
    charge_response["id"]
  end

  def credit_card_token_column
    'stripe_id'
  end

  def self.support_any_currency!
    true
  end

  def support_recurring_payment?
    true
  end

end
