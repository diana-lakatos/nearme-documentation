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
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:stripe_supported?).returns(true)
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
      assert_not_nil @gateway.processor
      assert @gateway.possible?
    end

    should 'know when processor is not available' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:stripe_supported?).returns(false)
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:paypal_supported?).returns(false)
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:balanced_supported?).returns(false)
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
      assert_nil @gateway.processor
      refute @gateway.possible?
    end

    should 'know when stripe is returned by factory' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:stripe_supported?).returns(true)
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
      assert_equal "Stripe", @gateway.processor.class.to_s.demodulize
    end

    should 'know when balanced is returned by factory' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:stripe_supported?).returns(false)
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:balanced_supported?).returns(true)
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
      assert_equal "Balanced", @gateway.processor.class.to_s.demodulize
    end

    should 'know when paypal is returned by factory' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:stripe_supported?).returns(false)
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:balanced_supported?).returns(false)
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:paypal_supported?).returns(true)
      @gateway = Billing::Gateway::Incoming.new(@user, @instance, 'USD')
      assert_equal "Paypal", @gateway.processor.class.to_s.demodulize
    end

  end
end
