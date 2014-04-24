require 'test_helper'

class Billing::Gateway::OutgoingTest < ActiveSupport::TestCase

  setup do
    @company = FactoryGirl.create(:company)
    @company.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
    @company.instance.instance_payment_gateways << FactoryGirl.create(:paypal_instance_payment_gateway)
    @company.instance.instance_payment_gateways << FactoryGirl.create(:balanced_instance_payment_gateway)
  end

  context 'initialize' do

    should 'ask processor factory for right processor' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.expects(:create).with(@company, 'USD')
      Billing::Gateway::Outgoing.new(@company, 'USD')
    end

    should 'know when processor is available' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(true)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_paypal?).returns(true)
      @gateway = Billing::Gateway::Outgoing.new(@company, 'USD')
      assert_not_nil @gateway.processor
      assert @gateway.possible?
    end

    context 'processor not available' do
      should 'not have processor if instance supported but receiver not' do
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(true)
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_paypal?).returns(false)
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(true)
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_balanced?).returns(false)
        @gateway = Billing::Gateway::Outgoing.new(@company, 'USD')
        assert_nil @gateway.processor
        refute @gateway.possible?
      end

      should 'not have processor if receiver supported but instance not' do
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(false)
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_paypal?).returns(true)
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(false)
        Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_balanced?).returns(true)
        @gateway = Billing::Gateway::Outgoing.new(@company, 'USD')
        assert_nil @gateway.processor
        refute @gateway.possible?
      end
    end

    should 'know when balanced is returned by factory' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(true)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_balanced?).returns(true)
      @gateway = Billing::Gateway::Outgoing.new(@company, 'USD')
      assert_equal "Balanced", @gateway.processor_class
    end

    should 'know when paypal is returned by factory' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(false)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(true)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:receiver_supports_paypal?).returns(true)
      @gateway = Billing::Gateway::Outgoing.new(@company, 'USD')
      assert_equal "Paypal", @gateway.processor_class
    end

  end


end
