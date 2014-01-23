require 'test_helper'

class Billing::GatewayTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @gateway = Billing::Gateway.new(@instance, 'USD')
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

  context 'outgoing_processor' do

    should 'know if there is outgoing processor that can potentially handle payment' do
      @gateway.stubs(:outgoing_processors).returns([mock()])
      assert @gateway.payout_possible?
    end

    should 'know if there is no outgoing processor that can potentially handle payment' do
      @gateway.stubs(:outgoing_processors).returns([])
      refute @gateway.payout_possible?
    end

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
  end


  context '#find_outgoing_processor_class' do

    context 'paypal' do

      setup do
        @gateway = Billing::Gateway.new(@instance, 'EUR')
      end

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

    end

    context 'balanced' do

      setup do
        @instance.update_attribute(:balanced_api_key, 'apikey123')
        @instance.update_attribute(:paypal_username, '')
        @gateway = Billing::Gateway.new(@instance, 'USD')
        @mock = mock()
      end

      should 'accept objects which have balanced api and currency' do
        @company = FactoryGirl.create(:company_with_balanced)
        assert Billing::Gateway::BalancedProcessor === @gateway.outgoing_payment(@instance, @company).processor, "#{@gateway.processor.class.name} is not BalancedProcessor"
      end

      should 'not accept objects which have balanced api but wrong currency' do
        @company = FactoryGirl.create(:company_with_balanced)
        @gateway = Billing::Gateway.new(@instance, 'EUR')
        assert_nil @gateway.outgoing_payment(@instance, @company).processor, "#{@gateway.processor.class.name} is not nil"
      end

      should 'not accept receiver without filled balanced info' do
        @company = FactoryGirl.create(:company)
        assert_nil @gateway.outgoing_payment(@instance, @company).processor, "#{@gateway.processor.class.name} is not nil"
      end

      should 'not accept sender without filled balanced api key' do
        @instance.update_attribute(:balanced_api_key, '')
        @company = FactoryGirl.create(:company_with_balanced)
        assert_nil @gateway.outgoing_payment(@instance, @company).processor, "#{@gateway.processor.class.name} is not nil"
      end

    end

  end

end
