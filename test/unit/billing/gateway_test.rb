require 'test_helper'

class Billing::GatewayTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @gateway = Billing::Gateway.new(@instance)
  end

  context 'processor' do

    should 'know if a processor can handle payment' do
      @gateway.stubs(:processor).returns(mock())
      assert @gateway.payment_supported?
    end

    should 'know if none processor can handle payment' do
      @gateway.stubs(:processor).returns(nil)
      refute @gateway.payment_supported?
    end

  end

  context '#ingoing_payment' do

    context 'stripe' do

      should 'accept USD' do
        assert Billing::Gateway::StripeProcessor === @gateway.ingoing_payment(@user, 'USD').processor
      end

    end

    context 'paypal' do
      should 'accept GBP' do
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user, 'GBP').processor
      end

      should 'accept JPY' do
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user, 'JPY').processor
      end

      should 'accept EUR' do
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user, 'EUR').processor
      end

      should 'accept CAD' do
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user, 'CAD').processor
      end
    end

    should 'return nil if currency is not supported by any processor' do
      assert_nil @gateway.ingoing_payment(@user, 'ABC').processor
    end

    context 'balanced' do

      context 'balanced is choosen in instance admin' do

        setup do
          FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'balanced', instance: @instance)
        end

        should 'not select balanced when balanced_api_key is not set' do
          refute @gateway.ingoing_payment(@user, 'USD').processor.is_a?(Billing::Gateway::BalancedProcessor)
        end

        should 'select balanced when balanced_api_key is set' do
          @instance.balanced_api_key = 'test'
          @instance.save
          assert Billing::Gateway::BalancedProcessor === @gateway.ingoing_payment(@user, 'USD').processor
        end
      end

      context 'balanced is not choosen in instance admin' do

        setup do
          FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'stripe', instance: @instance)
        end

        should 'not select balanced' do
          refute @gateway.ingoing_payment(@user, 'USD').processor.is_a?(Billing::Gateway::BalancedProcessor)
        end

        should 'not select balanced even when balanced_api_key is set' do
          @instance.balanced_api_key = 'test'
          @instance.save
          refute @gateway.ingoing_payment(@user, 'USD').processor.is_a?(Billing::Gateway::BalancedProcessor)
        end
      end
    end
  end


  context '#find_outgoing_processor_class' do

    context 'paypal' do

      should 'accept objects which have paypal email' do
        @mock = mock()
        @mock.expects(:paypal_email).returns('paypal@example.com').twice
        assert Billing::Gateway::PaypalProcessor === @gateway.outgoing_payment(@mock, @mock).processor
      end

      should 'not accept objects with blank paypal_email' do
        @mock = mock()
        @mock.expects(:paypal_email).returns('')
        assert_nil @gateway.outgoing_payment(@mock, @mock).processor
      end

      should 'not accept objects without paypal_email' do
        @mock = mock()
        assert_nil @gateway.outgoing_payment(@mock, @mock).processor
      end

    end

  end

end
