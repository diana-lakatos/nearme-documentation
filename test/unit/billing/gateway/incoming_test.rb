require 'test_helper'

class Billing::Gateway::IncomingTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
  end

  context 'initialize' do
    
    should 'ask processor factory for right processor' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.expects(:create).with(@user, @instance, 'USD')
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
    end

    should 'know when processor is available' do
      ipg = FactoryGirl.create(:stripe_instance_payment_gateway)
      @instance.instance_payment_gateways << ipg
      
      country_ipg = FactoryGirl.create(
        :country_instance_payment_gateway, 
        country_alpha2_code: "US", 
        instance_payment_gateway_id: ipg.id
      )

      @instance.country_instance_payment_gateways << country_ipg

      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
      
      assert_not_nil @gateway.processor
      assert @gateway.possible?
      assert_equal Billing::Gateway::Processor::Incoming::Stripe, @gateway.processor.class
    end

    should 'know when processor is not available' do
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
      assert_nil @gateway.processor
      refute @gateway.possible?
    end

  end
end
