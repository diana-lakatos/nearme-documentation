require 'test_helper'

class Billing::Gateway::Processor::Incoming::FetchTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.first
    @user = FactoryGirl.create(:user)
    @user.update_attribute :country_name, "New Zealand"
    @instance.country_instance_payment_gateways << FactoryGirl.create(:fetch_country_instance_payment_gateway)
    ActiveMerchant::Billing::Base.mode = :test
    @billing_gateway = Billing::Gateway::Incoming.new(@user, @instance, 'NZD')
  end

  should "set fetch as processor for NZ users" do
    assert_equal @billing_gateway.processor.class, Billing::Gateway::Processor::Incoming::Fetch
  end
end
