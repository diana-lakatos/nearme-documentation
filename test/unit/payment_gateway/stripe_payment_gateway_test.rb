require 'test_helper'

class PaymentGateway::StripePaymentGatewayTest < ActiveSupport::TestCase
  setup do
    @stripe_processor = PaymentGateway::StripePaymentGateway.new
  end

  should 'include test in settings' do
    assert @stripe_processor.settings[:test]
  end

  should '#setup_api_on_initialize should return a ActiveMerchant StripeGateway object' do
    assert_equal ActiveMerchant::Billing::StripeGateway, @stripe_processor.class.active_merchant_class
  end

  should 'have a refund identification based on its id key' do
    charge_response = ActiveMerchant::Billing::Response.new true, 'OK', 'id' => '123', 'message' => 'message'
    charge = Charge.new(response: charge_response)
    assert_equal '123', @stripe_processor.refund_identification(charge)
  end
end
