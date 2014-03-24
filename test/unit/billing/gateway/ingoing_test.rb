require 'test_helper'

class Billing::Gateway::IngoingTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
  end



  context 'stripe' do

    should 'accept USD' do
      assert_equal "Stripe", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
    end

  end

  context 'paypal' do
    should 'accept GBP' do
      assert_equal "Paypal", Billing::Gateway::Ingoing.new(@user, @instance, 'GBP').processor.class.to_s.demodulize
    end

    should 'accept JPY' do
      assert_equal "Paypal", Billing::Gateway::Ingoing.new(@user, @instance, 'JPY').processor.class.to_s.demodulize
    end

    should 'accept EUR' do
      assert_equal "Paypal", Billing::Gateway::Ingoing.new(@user, @instance, 'EUR').processor.class.to_s.demodulize
    end

    should 'accept CAD' do
      assert_equal "Paypal", Billing::Gateway::Ingoing.new(@user, @instance, 'CAD').processor.class.to_s.demodulize
    end
  end

  should 'return nil if currency is not supported by any processor' do
      assert_nil Billing::Gateway::Ingoing.new(@user, @instance, 'ABC').processor
  end

  context 'balanced' do

    context 'balanced is choosen in instance admin' do

      setup do
        FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'balanced', instance: @instance)
      end

      should 'not select balanced when balanced_api_key is not set' do
        assert_not_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end

      should 'select balanced when balanced_api_key is set' do
        @instance.update_attribute(:balanced_api_key, 'test')
        assert_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end
    end

    context 'balanced is not choosen in instance admin' do

      setup do
        FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'stripe', instance: @instance)
      end

      should 'not select balanced' do
        assert_not_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end

      should 'not select balanced even when balanced_api_key is set' do
        @instance.update_attribute(:balanced_api_key, 'test')
        assert_not_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end
    end
  end

  context 'balanced' do

    context 'balanced is choosen in instance admin' do

      setup do
        FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'balanced', instance: @instance)
      end

      should 'not select balanced when balanced_api_key is not set' do
        assert_not_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end

      should 'select balanced when balanced_api_key is set' do
        @instance.update_attribute(:balanced_api_key, 'test')
        assert_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end
    end

    context 'balance is not choosen in instance admin' do

      setup do
        FactoryGirl.create(:instance_billing_gateway, billing_gateway: 'stripe', instance: @instance)
      end

      should 'not select balanced' do
        assert_not_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end

      should 'not select balanced even when balanced_api_key is set' do
        @instance.update_attribute(:balanced_api_key, 'test')
        assert_not_equal "Balanced", Billing::Gateway::Ingoing.new(@user, @instance, 'USD').processor.class.to_s.demodulize
      end
    end
  end
end
