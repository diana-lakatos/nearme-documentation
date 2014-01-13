require 'test_helper'

class Billing::GatewayTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
  end

  context 'processor' do

    setup do
      @gateway = Billing::Gateway.new(@instance)
    end

    should 'know if a processor can handle payment' do
      @gateway.stubs(:processor).returns(mock())
      assert @gateway.payment_supported?
    end

    should 'know if none processor can handle payment' do
      @gateway.stubs(:processor).returns(nil)
      refute @gateway.payment_supported?
    end

    context 'ingoing' do
      setup do
        @currency = 'USD'
        @gateway = Billing::Gateway.new(@instance)
      end

      should 'initialize correct object' do
        stripe_processor_instance_mock = mock()
        stripe_processor_instance_mock.expects(:ingoing_payment).with(@user, @currency).once
        Billing::Gateway::StripeProcessor.expects(:new).with(@instance).returns(stripe_processor_instance_mock)
        Billing::Gateway::BaseProcessor.stubs(:find_ingoing_processor_class).with(@currency).returns(Billing::Gateway::StripeProcessor)
        @gateway.ingoing_payment(@user, @currency)
      end
    end

    context 'outgoing' do

      setup do
        @sender = Instance.default_instance
        @receiver = FactoryGirl.create(:company)
        @gateway = Billing::Gateway.new(@instance)
      end

      should 'initialize correct object' do
        paypal_processor_instance_mock = mock()
        paypal_processor_instance_mock.expects(:outgoing_payment).with(@sender, @receiver).once
        Billing::Gateway::PaypalProcessor.expects(:new).with(@instance).returns(paypal_processor_instance_mock)
        Billing::Gateway::BaseProcessor.stubs(:find_outgoing_processor_class).with(@sender, @receiver).returns(Billing::Gateway::PaypalProcessor)
        @gateway.outgoing_payment(@sender, @receiver)
      end
    end
  end

end
