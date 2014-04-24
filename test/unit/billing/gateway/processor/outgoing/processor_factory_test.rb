require 'test_helper'

class Billing::Gateway::Processor::Outgoing::ProcessorFactoryTest < ActiveSupport::TestCase

  context 'balanced' do
    context 'receiver_supports_balanced?' do

      setup do
        @company = FactoryGirl.create(:company)
        @company.instance.instance_payment_gateways << FactoryGirl.create(:balanced_instance_payment_gateway)
      end

      should 'support balanced if instance_client with the right instance exists and has balanced_user_id' do
        FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance, :balanced_user_id => 'present')
        assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.receiver_supports_balanced?(@company)
      end

      should 'not support balanced if instance_client exists but for other instance' do
        FactoryGirl.create(:instance_client, :client => @company, :balanced_user_id => 'present').update_column(:instance_id, FactoryGirl.create(:instance).id)
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.receiver_supports_balanced?(@company)
      end

      should 'not support balanced if instance_client with the right instance exists but without balanced_user_id' do
        FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance)
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.receiver_supports_balanced?(@company)
      end

      should 'not support balanced if instance_client does not exist' do
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.receiver_supports_balanced?(@company)
      end
    end

    context 'balanced_supported?' do

      setup do
        @instance = Instance.default_instance
        @instance.instance_payment_gateways << FactoryGirl.create(:balanced_instance_payment_gateway)
      end

      should 'support balanced if has specified api' do
        assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.balanced_supported?(@instance, 'USD')
      end

      should 'not support balanced if has not specified api' do
        @instance.instance_payment_gateways.set_settings_for(:balanced, {login: ""})
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.balanced_supported?(@instance, 'USD')
      end

      context 'currency' do

        should 'support balanced if has specified api but wrong currency' do
          @instance.instance_payment_gateways.set_settings_for(:balanced, {login: "present"})
          refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.balanced_supported?(@instance, 'ABC')
        end

      end
    end

  end

  context 'paypal' do

    context 'receiver_supports_paypal?' do

      setup do
        @company = FactoryGirl.create(:company)
      end

      should 'support paypal if has paypal email' do
        @company.paypal_email = "example@example.com"
        assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.receiver_supports_paypal?(@company)
      end

      should 'not support paypal if paypal email empty' do
        @company.paypal_email = " "
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.receiver_supports_paypal?(@company)
      end

      should 'not support paypal if paypal email nil' do
        @company.paypal_email = nil
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.receiver_supports_paypal?(@company)
      end

    end

    context 'paypal_supported?' do
      setup do
        @instance = Instance.default_instance
        @instance.instance_payment_gateways << FactoryGirl.create(:paypal_instance_payment_gateway)
      end

      should 'support paypal if has all necessary details' do
        assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal if has all necessary details but wrong currency' do
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'ABC')
      end

      should 'not support paypal without username' do
        @instance.instance_payment_gateways.set_settings_for(:paypal, {login: ""})
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal without password' do
        @instance.instance_payment_gateways.set_settings_for(:paypal, {password: ""})
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal without signature' do
        @instance.instance_payment_gateways.set_settings_for(:paypal, {signature: ""})
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal without app_id' do
        @instance.instance_payment_gateways.set_settings_for(:paypal, {app_id: ""})
        refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      context 'currency' do

        should 'accept GBP' do
          assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'GBP')
        end

        should 'accept JPY' do
          assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'JPY')
        end

        should 'accept EUR' do
          assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'EUR')
        end

        should 'accept CAD' do
          assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'CAD')
        end

        should 'not support paypal if has all necessary details but wrong currency' do
          refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.paypal_supported?(@instance, 'ABC')
        end

      end
    end

  end

  context 'support_automated_payout?' do

    should 'not be supported if both balanced and paypal are not available' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(false).at_least(0)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(false).at_least(0)
      refute Billing::Gateway::Processor::Outgoing::ProcessorFactory.support_automated_payout?(nil, nil)
    end

    should 'be supported paypal is available' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(false).at_least(0)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(true).at_least(0)
      assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.support_automated_payout?(nil, nil)
    end

    should 'be supported balanced is supported' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(false).at_least(0)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(true).at_least(0)
      assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.support_automated_payout?(nil, nil)
    end

    should 'be supported if both balanced and paypal are supported' do
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:paypal_supported?).returns(true).at_least(0)
      Billing::Gateway::Processor::Outgoing::ProcessorFactory.stubs(:balanced_supported?).returns(true).at_least(0)
      assert Billing::Gateway::Processor::Outgoing::ProcessorFactory.support_automated_payout?(nil, nil)
    end
  end
end
