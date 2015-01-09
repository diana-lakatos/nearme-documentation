require 'test_helper'

class Billing::Gateway::Processor::Incoming::PaypalTest < ActiveSupport::TestCase

  setup do
    @instance = FactoryGirl.create(:instance_test_mode)
    @user = FactoryGirl.create(:user)
    @instance.instance_payment_gateways << FactoryGirl.create(:paypal_instance_payment_gateway)
    Billing::Gateway::Processor::Incoming::Paypal.any_instance.stubs(:setup_api_on_initialize)
    @paypal_processor = Billing::Gateway::Processor::Incoming::Paypal.new(@user, @instance, 'USD')
  end

  should "#setup_api_on_initialize should return a ActiveMerchant PaypalGateway object" do
    assert_equal @paypal_processor.active_merchant_class, ActiveMerchant::Billing::PaypalGateway
  end

  should "have a refund identification based on its transaction_id key" do
    charge_response = ActiveMerchant::Billing::Response.new true, 'OK', { "transaction_id" => "123" }
    charge = Charge.new(response: charge_response)
    assert_equal @paypal_processor.refund_identification(charge), "123"
  end

end
