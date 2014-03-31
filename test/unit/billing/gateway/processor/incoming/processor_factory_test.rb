require 'test_helper'

class Billing::Gateway::Processor::Incoming::ProcessorFactoryTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
  end

  context 'stripe_supported?' do
    setup do
      @instance.stripe_api_key = 'a'
      @instance.stripe_public_key = 'b'
    end

    should 'support stripe if has all necessary details' do
      assert Billing::Gateway::Processor::Incoming::ProcessorFactory.stripe_supported?(@instance, 'USD')
    end

    should 'not support stripe without api key' do
      @instance.stripe_api_key = ''
      refute Billing::Gateway::Processor::Incoming::ProcessorFactory.stripe_supported?(@instance, 'USD')
    end

    should 'not support stripe without public key' do
      @instance.stripe_public_key = ''
      refute Billing::Gateway::Processor::Incoming::ProcessorFactory.stripe_supported?(@instance, 'USD')
    end

    context 'currency' do
      should 'not support stripe if wrong currency' do
        refute Billing::Gateway::Processor::Incoming::ProcessorFactory.stripe_supported?(@instance, 'ABC')
      end
    end
  end

  context 'balanced_supported?' do


    should 'support balanced if has specified api' do
      @instance.balanced_api_key = '123'
      assert Billing::Gateway::Processor::Incoming::ProcessorFactory.balanced_supported?(@instance, 'USD')
    end

    should 'support balanced if has specified api but wrong currency' do
      @instance.balanced_api_key = '123'
      refute Billing::Gateway::Processor::Incoming::ProcessorFactory.balanced_supported?(@instance, 'ABC')
    end

    should 'not support balanced if has not specified api' do
      @instance.balanced_api_key = ''
      refute Billing::Gateway::Processor::Incoming::ProcessorFactory.balanced_supported?(@instance, 'USD')
    end

  end

  context 'paypal_supported?' do
    setup do
      @instance.paypal_username = 'a'
      @instance.paypal_password = 'b'
      @instance.paypal_signature =  'c'
      @instance.paypal_client_id = 'd'
      @instance.paypal_client_secret = 'e'
      @instance.paypal_app_id = 'f'
    end

    should 'support paypal if has all necessary details' do
      assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
    end

    should 'not support paypal without username' do
      @instance.paypal_username = ''
      assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
    end

    should 'not support paypal without password' do
      @instance.paypal_password = ''
      assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
    end

    should 'not support paypal without signature' do
      @instance.paypal_signature = ''
      assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
    end

    should 'not support paypal without client_id' do
      @instance.paypal_client_id = ''
      refute Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
    end

    should 'support paypal without client_secret' do
      @instance.paypal_client_secret = ''
      refute Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
    end

    should 'not support paypal without app_id' do
      @instance.paypal_app_id = ''
      assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
    end

    context 'currency' do

      should 'accept GBP' do
        assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'GBP')
      end

      should 'accept JPY' do
        assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'JPY')
      end

      should 'accept EUR' do
        assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'EUR')
      end

      should 'accept CAD' do
        assert Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'CAD')
      end

      should 'not support paypal if has all necessary details but wrong currency' do
        refute Billing::Gateway::Processor::Incoming::ProcessorFactory.paypal_supported?(@instance, 'ABC')
      end

    end
  end

  context 'billing_gateway_for' do

    setup do
      FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'balanced', instance: @instance)
    end

    should 'not try to find processor if billing gateway filled' do
      mock = mock()
      stub = stub(:new => mock)
      Billing::Gateway::Processor::Incoming::ProcessorFactory.expects(:stripe_supported?).never
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:billing_gateway_for).returns(stub)
      assert_equal mock, Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @instance, 'USD')
    end

    should 'try to find processor if billing gateway returns nil' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.expects(:stripe_supported?).once
      Billing::Gateway::Processor::Incoming::ProcessorFactory.stubs(:billing_gateway_for).returns(nil)
      Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @instance, 'USD')
    end

    should 'select balanced when balanced_api_key is set but wrong currency' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.expects(:stripe_supported?).never
      @instance.update_attribute(:balanced_api_key, 'test')
      assert_equal 'Balanced', Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @instance, 'USD').class.to_s.demodulize
    end

    should 'not select balanced when balanced_api_key is set but wrong currency' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.expects(:stripe_supported?).once
      @instance.update_attribute(:balanced_api_key, 'test')
      assert_not_equal 'Balanced', Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@user, @instance, 'ABC').class.to_s.demodulize
    end

    should 'not select balanced when balanced_api_key is not set' do
      Billing::Gateway::Processor::Incoming::ProcessorFactory.expects(:stripe_supported?).once
      assert_not_equal 'Balanced', Billing::Gateway::Processor::Incoming::ProcessorFactory.create(@usr, @instance, 'USD').class.to_s.demodulize
    end

  end

end
