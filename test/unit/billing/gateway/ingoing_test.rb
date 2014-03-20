require 'test_helper'

class Billing::Gateway::IngoingTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @gateway = Billing::Gateway.new(@instance, 'USD')
  end


  context '#ingoing_payment' do

    context 'stripe' do

      should 'accept USD' do

        @gateway = Billing::Gateway.new(@instance, 'USD')
        assert Billing::Gateway::StripeProcessor === @gateway.ingoing_payment(@user).processor
      end

    end

    context 'paypal' do
      should 'accept GBP' do
        @gateway = Billing::Gateway.new(@instance, 'GBP')
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user).processor
      end

      should 'accept JPY' do
        @gateway = Billing::Gateway.new(@instance, 'JPY')
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user).processor
      end

      should 'accept EUR' do
        @gateway = Billing::Gateway.new(@instance, 'EUR')
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user).processor
      end

      should 'accept CAD' do
        @gateway = Billing::Gateway.new(@instance, 'CAD')
        assert Billing::Gateway::PaypalProcessor === @gateway.ingoing_payment(@user).processor
      end
    end

    should 'return nil if currency is not supported by any processor' do
      @gateway = Billing::Gateway.new(@instance, 'ABC')
      assert_nil @gateway.ingoing_payment(@user).processor
    end

    context 'balanced' do

      context 'balanced is choosen in instance admin' do

        setup do
          FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'balanced', instance: @instance)
        end

        should 'not select balanced when balanced_api_key is not set' do
          refute @gateway.ingoing_payment(@user).processor.is_a?(Billing::Gateway::BalancedProcessor)
        end

        should 'select balanced when balanced_api_key is set' do
          @instance.balanced_api_key = 'test'
          @instance.save
          @gateway = Billing::Gateway.new(@instance, 'USD')
          assert Billing::Gateway::BalancedProcessor === @gateway.ingoing_payment(@user).processor
        end
      end

      context 'balanced is not choosen in instance admin' do

        setup do
          FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'stripe', instance: @instance)
        end

        should 'not select balanced' do
          refute @gateway.ingoing_payment(@user).processor.is_a?(Billing::Gateway::BalancedProcessor)
        end

        should 'not select balanced even when balanced_api_key is set' do
          @instance.balanced_api_key = 'test'
          @instance.save
          @gateway = Billing::Gateway.new(@instance, 'USD')
          refute @gateway.ingoing_payment(@user).processor.is_a?(Billing::Gateway::BalancedProcessor)
        end
      end
    end

    context 'balanced' do

      context 'balanced is choosen in instance admin' do

        setup do
          FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'balanced', instance: @instance)
        end

        should 'not select balanced when balanced_api_key is not set' do
          refute @gateway.ingoing_payment(@user).processor.is_a?(Billing::Gateway::BalancedProcessor)
        end

        should 'select balanced when balanced_api_key is set' do
          @instance.balanced_api_key = 'test'
          @instance.save
          assert Billing::Gateway::BalancedProcessor === @gateway.ingoing_payment(@user).processor
        end
      end

      context 'balanced is not choosen in instance admin' do

        setup do
          FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'stripe', instance: @instance)
        end

        should 'not select balanced' do
          refute @gateway.ingoing_payment(@user).processor.is_a?(Billing::Gateway::BalancedProcessor)
        end

        should 'not select balanced even when balanced_api_key is set' do
          @instance.balanced_api_key = 'test'
          @instance.save
          refute @gateway.ingoing_payment(@user).processor.is_a?(Billing::Gateway::BalancedProcessor)
        end
      end
    end
  end



end
