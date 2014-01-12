require 'test_helper'

class Billing::GatewayTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
  end

  context 'processor' do
    setup do
      @currency = 'CAD'
      @gateway = Billing::Gateway.new(@user, @currency, @instance)
    end

    should 'know if a processor can handle payment' do
      @gateway.stubs(:processor).returns(mock())
      assert @gateway.payment_supported?
    end

    should 'know if none processor can handle payment' do
      @gateway.stubs(:processor).returns(nil)
      refute @gateway.payment_supported?
    end

    should 'initialize correct object' do
      Billing::Gateway::StripeProcessor.expects(:new).with(@user, @currency, @instance).once
      Billing::Gateway::BaseProcessor.stubs(:find_processor_class).with(@currency).returns(Billing::Gateway::StripeProcessor)
      @gateway.processor
    end

  end

end
