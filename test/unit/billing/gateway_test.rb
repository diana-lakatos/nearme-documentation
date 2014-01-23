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
  end


  context '#find_outgoing_processor_class' do

    context 'paypal' do

      should 'accept objects which have paypal email' do
        @mock = mock()
        @mock.expects(:paypal_email).returns('paypal@example.com').twice
        assert Billing::Gateway::PaypalProcessor === @gateway.outgoing_payment(@mock, @mock, 'EUR').processor
      end

      should 'not accept objects with blank paypal_email' do
        @mock = mock()
        @mock.expects(:paypal_email).returns('')
        assert_nil @gateway.outgoing_payment(@mock, @mock, 'EUR').processor
      end

    end

    context 'balanced' do

      setup do
        @instance.update_attribute(:balanced_api_key, 'apikey123')
        @gateway = Billing::Gateway.new(@instance)
        @mock = mock()
        @mock.expects(:paypal_email).returns('')
      end

      should 'accept objects which have balanced api and currency' do
        @mock.expects(:balanced_api_key).returns('balanced_api_key123')
        @company = FactoryGirl.create(:company_with_balanced)
        assert Billing::Gateway::BalancedProcessor === @gateway.outgoing_payment(@mock, @company, 'USD').processor
      end

      should 'not accept objects which have balanced api but wrong currency' do
        @mock.expects(:balanced_api_key).returns('balanced_api_key123').at_least(0)
        @company = FactoryGirl.create(:company_with_balanced)
        assert_nil @gateway.outgoing_payment(@mock, @company, 'EUR').processor
      end

      should 'not accept receiver without filled balanced info' do
        @mock.expects(:balanced_api_key).returns('balanced_api_key123')
        @company = FactoryGirl.create(:company)
        assert_nil @gateway.outgoing_payment(@mock, @company, 'USD').processor
      end

      should 'not accept sender without filled balanced api key' do
        @mock.expects(:balanced_api_key).returns('')
        @company = FactoryGirl.create(:company_with_balanced)
        assert_nil @gateway.outgoing_payment(@mock, @company, 'USD').processor
      end

    end

  end

end
