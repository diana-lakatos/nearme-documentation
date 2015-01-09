require 'test_helper'

class Billing::Gateway::Processor::Incoming::BraintreeTest < ActiveSupport::TestCase

  setup do
    @instance = FactoryGirl.create(:instance_test_mode)
    @user = FactoryGirl.create(:user)
    @instance.instance_payment_gateways << FactoryGirl.create(:braintree_instance_payment_gateway)
    ActiveMerchant::Billing::Base.mode = :test
    @braintree_processor = Billing::Gateway::Processor::Incoming::Braintree.new(@user, @instance, 'USD')
  end


  should "#setup_api_on_initialize should return a ActiveMerchant StripeGateway object" do
    assert_equal @braintree_processor.active_merchant_class, ActiveMerchant::Billing::BraintreeBlueGateway
  end

  # should "have a refund identification based on its id key" do
  #   charge_response = { "id" => "123", "message" => "message" }
  #   assert_equal @braintree_processor.refund_identification(charge_response), "123"
  # end
end