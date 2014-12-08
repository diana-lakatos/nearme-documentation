require 'test_helper'

class Billing::Gateway::Processor::Incoming::FetchTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.first
    @user = FactoryGirl.create(:user)
    @instance.country_instance_payment_gateways << FactoryGirl.create(:fetch_country_instance_payment_gateway)
    ActiveMerchant::Billing::Base.mode = :test
  end

  should "set fetch as processor for NZ companies" do
    @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, 'NZD', 'NZ')
    assert_equal Billing::Gateway::Processor::Incoming::Fetch, @billing_gateway.processor.class
  end

  should "not set fetch as processor for US companies" do
    @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, 'NZD', 'US')
    assert_nil @billing_gateway.processor
  end

  should "not set fetch as processor for NZ companies but with USD" do
    @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD', 'NZ')
    assert_nil @billing_gateway.processor
  end
end
