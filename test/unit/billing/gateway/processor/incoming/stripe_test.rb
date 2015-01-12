require 'test_helper'

class Billing::Gateway::Processor::Incoming::StripeTest < ActiveSupport::TestCase

  setup do
    @instance = FactoryGirl.create(:instance_test_mode)
    @user = FactoryGirl.create(:user)
    @instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
    ActiveMerchant::Billing::Base.mode = :test
    @stripe_processor = Billing::Gateway::Processor::Incoming::Stripe.new(@user, @instance, 'USD')
  end


  should "#setup_api_on_initialize should return a ActiveMerchant StripeGateway object" do
    assert_equal @stripe_processor.active_merchant_class, ActiveMerchant::Billing::StripeGateway
  end

  should "have a refund identification based on its id key" do
    charge_response = ActiveMerchant::Billing::Response.new true, 'OK', { "id" => "123", "message" => "message" }
    charge = Charge.new(response: charge_response)
    assert_equal @stripe_processor.refund_identification(charge), "123"
  end
end