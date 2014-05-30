require 'test_helper'
require 'vcr_setup'

class Billing::Gateway::Processor::Incoming::BalancedTest < ActiveSupport::TestCase

  setup do
    @instance = FactoryGirl.create(:instance_test_mode)
    @user = FactoryGirl.create(:user)
    @instance.instance_payment_gateways << FactoryGirl.create(:balanced_instance_payment_gateway)
    ActiveMerchant::Billing::Base.mode = :test
    Billing::Gateway::Processor::Incoming::Balanced.any_instance.stubs(:setup_api_on_initialize)
    @balanced_processor = Billing::Gateway::Processor::Incoming::Balanced.new(@user, @instance, 'USD')
  end

  should "#setup_api_on_initialize should return a ActiveMerchant BalancedGateway object" do
    assert_equal @balanced_processor.active_merchant_class, ActiveMerchant::Billing::BalancedGateway
  end

  should "have a refund identification based on its uri key" do
    charge_response = { "id" => "123", "uri" => "uri" }
    assert_equal @balanced_processor.refund_identification(charge_response), "uri"
  end

end
