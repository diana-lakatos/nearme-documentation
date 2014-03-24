require 'test_helper'

class Billing::Gateway::Processor::Outcoming::ProcessorFactoryTest < ActiveSupport::TestCase

  context 'balanced' do
    context 'receiver_supports_balanced?' do

      setup do
        @company = FactoryGirl.create(:company)
        @company.instance.update_attribute(:balanced_api_key, 'present')
      end

      should 'support balanced if instance_client with the right instance exists and has balanced_user_id' do
        FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance, :balanced_user_id => 'present')
        assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.receiver_supports_balanced?(@company)
      end

      should 'not support balanced if instance_client exists but for other instance' do
        FactoryGirl.create(:instance_client, :client => @company, :balanced_user_id => 'present').update_column(:instance_id, FactoryGirl.create(:instance).id)
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.receiver_supports_balanced?(@company)
      end

      should 'not support balanced if instance_client with the right instance exists but without balanced_user_id' do
        FactoryGirl.create(:instance_client, :client => @company, :instance => @company.instance)
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.receiver_supports_balanced?(@company)
      end

      should 'not support balanced if instance_client does not exist' do
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.receiver_supports_balanced?(@company)
      end
    end

    context 'balanced_supported?' do

      setup do
        @instance = Instance.default_instance
      end

      should 'support balanced if has specified api' do
        @instance.balanced_api_key = '123'
        assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.balanced_supported?(@instance, 'USD')
      end

      should 'support balanced if has specified api but wrong currency' do
        @instance.balanced_api_key = '123'
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.balanced_supported?(@instance, 'ABC')
      end

      should 'not support balanced if has not specified api' do
        @instance.balanced_api_key = ''
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.balanced_supported?(@instance, 'USD')
      end
    end

  end

  context 'paypal' do

    context 'receiver_supports_paypal?' do

      setup do
        @company = FactoryGirl.create(:company)
      end

      should 'support paypal if has paypal email' do
        @company.paypal_email = 'abc'
        assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.receiver_supports_paypal?(@company)
      end

      should 'not support paypal if paypal email empty' do
        @company.paypal_email = '    '
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.receiver_supports_paypal?(@company)
      end

      should 'not support paypal if paypal email nil' do
        @company.paypal_email = nil
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.receiver_supports_paypal?(@company)
      end

    end

    context 'paypal_supported?' do
      setup do
        @instance = Instance.default_instance
        @instance.paypal_username = 'a'
        @instance.paypal_password = 'b'
        @instance.paypal_signature =  'c'
        @instance.paypal_client_id = 'd'
        @instance.paypal_client_secret = 'e'
        @instance.paypal_app_id = 'f'
      end

      should 'support paypal if has all necessary details' do
        assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal if has all necessary details but wrong currency' do
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'ABC')
      end

      should 'not support paypal without username' do
        @instance.paypal_username = ''
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal without password' do
        @instance.paypal_password = ''
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal without signature' do
        @instance.paypal_signature = ''
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal without client_id' do
        @instance.paypal_client_id = ''
        assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'support paypal without client_secret' do
        @instance.paypal_client_secret = ''
        assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end

      should 'not support paypal without app_id' do
        @instance.paypal_app_id = ''
        refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.paypal_supported?(@instance, 'USD')
      end
    end

  end

  context 'support_automated_payout?' do

    should 'not be supported if both balanced and paypal are not available' do
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:balanced_supported?).returns(false).at_least(0)
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:paypal_supported?).returns(false).at_least(0)
      refute Billing::Gateway::Processor::Outcoming::ProcessorFactory.support_automated_payout?(nil, nil)
    end

    should 'be supported paypal is available' do
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:balanced_supported?).returns(false).at_least(0)
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:paypal_supported?).returns(true).at_least(0)
      assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.support_automated_payout?(nil, nil)
    end

    should 'be supported balanced is supported' do
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:paypal_supported?).returns(false).at_least(0)
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:balanced_supported?).returns(true).at_least(0)
      assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.support_automated_payout?(nil, nil)
    end

    should 'be supported if both balanced and paypal are supported' do
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:paypal_supported?).returns(true).at_least(0)
      Billing::Gateway::Processor::Outcoming::ProcessorFactory.stubs(:balanced_supported?).returns(true).at_least(0)
      assert Billing::Gateway::Processor::Outcoming::ProcessorFactory.support_automated_payout?(nil, nil)
    end
  end
end
