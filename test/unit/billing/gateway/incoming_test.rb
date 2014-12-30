require 'test_helper'

class Billing::Gateway::IncomingTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @country = 'US'
  end

  context 'initialize' do

    should 'ask processor factory for right processor' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.expects(:create).with(@user, @instance, 'USD', @country)
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD', @country )
    end

    should 'know when processor is available' do
      stub_billing_gateway(@instance)

      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD', @country)

      assert_not_nil @gateway.processor
      assert @gateway.possible?
      assert_equal Billing::Gateway::Processor::Incoming::Stripe, @gateway.processor.class
    end

    should 'know when processor is not available' do
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD', @country)
      assert_nil @gateway.processor
      refute @gateway.possible?
    end

  end
end
