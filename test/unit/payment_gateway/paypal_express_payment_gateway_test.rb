require 'test_helper'

class PaymentGateway::PaypalExpressPaymentGatewayTest < ActiveSupport::TestCase
  setup do
    @paypal_express_processor = FactoryGirl.build(:paypal_express_payment_gateway)
  end

  should '#setup_api_on_initialize should return a ActiveMerchant PaypalGateway object' do
    assert_equal ActiveMerchant::Billing::PaypalExpressGateway, @paypal_express_processor.class.active_merchant_class
  end

  should 'include test in settings' do
    assert @paypal_express_processor.settings[:test]
  end

  should 'have a refund identification based on its transaction_id key' do
    charge_response = ActiveMerchant::Billing::Response.new true, 'OK', 'transaction_id' => '123'
    charge = Charge.new(response: charge_response)
    assert_equal '123', @paypal_express_processor.refund_identification(charge)
  end
end
