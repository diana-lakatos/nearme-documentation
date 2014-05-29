require 'test_helper'

class Billing::Gateway::Processor::Incoming::ProcessorFactoryTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
  end


  context "create" do
    should "select payment gateway based on user's country" do
      stripe = FactoryGirl.create(:stripe_instance_payment_gateway)
      paypal = FactoryGirl.create(:paypal_instance_payment_gateway)

      @instance.instance_payment_gateways << [stripe, paypal]

      us = FactoryGirl.create(
       :country_instance_payment_gateway, 
       country_alpha2_code: "US", 
       instance_payment_gateway_id: paypal.id
      )

      @instance.country_instance_payment_gateways << us

      processor = Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @instance, "USD")
      assert_equal Billing::Gateway::Processor::Incoming::Paypal, processor.class
      assert_equal us.country_alpha2_code, @user.country.alpha2
    end

    should "return nil if there isn't a available gateway for that country" do
      paypal = FactoryGirl.create(:paypal_instance_payment_gateway)
      
      @instance.instance_payment_gateways << paypal

      ca = FactoryGirl.create(
       :country_instance_payment_gateway, 
       country_alpha2_code: "CA", 
       instance_payment_gateway_id: paypal.id
      )

      processor = Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @instance, "USD")

      assert_nil processor
      assert_not_equal ca.country_alpha2_code, @user.country.alpha2
    end
  end

end
