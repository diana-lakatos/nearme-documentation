require 'test_helper'

class Billing::Gateway::OutgoingTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.create(:reservation)
    @gateway = Billing::Gateway.new(@instance, 'USD')
  end

  context 'outgoing_processor' do

    setup do
      @mock = mock()
      @mock.expects(:instance).returns(@instance)
      @mock.expects(:paypal_email).returns('paypal@example.com').at_least(0)
    end

    should 'know if there is outgoing processor that can potentially handle payment' do
      @gateway.outgoing_payment(@mock)
      assert @gateway.payout_possible?
    end

    should 'know if there is no outgoing processor that can potentially handle payment' do
      @gateway = Billing::Gateway.new(@instance, 'ABC').outgoing_payment(@mock)
      refute @gateway.payout_possible?
    end

  end

  context '#find_outgoing_processor_class' do

    context 'paypal' do

      setup do
        @gateway = Billing::Gateway.new(@instance, 'EUR')
        @mock = mock()
        @mock.expects(:instance).returns(@instance)
      end

      should 'accept objects which have paypal email' do
        @mock.expects(:paypal_email).returns('paypal@example.com')
        assert Billing::Gateway::PaypalProcessor === @gateway.outgoing_payment(@mock).processor
      end

      should 'not accept objects with blank paypal_email' do
        @mock.expects(:paypal_email).returns('')
        assert_nil @gateway.outgoing_payment(@mock).processor
      end

    end

    context 'balanced' do

      setup do
        @instance.update_attribute(:balanced_api_key, 'apikey123')
        @instance.update_attribute(:paypal_username, '')
        @gateway = Billing::Gateway.new(@instance, 'USD')
      end

      should 'accept objects which have balanced api and currency' do
        @company = FactoryGirl.create(:company_with_balanced)
        assert Billing::Gateway::BalancedProcessor === @gateway.outgoing_payment(@company).processor, "#{@gateway.processor.class.name} is not BalancedProcessor"
      end

      should 'not accept objects which have balanced api but wrong currency' do
        @company = FactoryGirl.create(:company_with_balanced)
        @gateway = Billing::Gateway.new(@instance, 'EUR')
        assert_nil @gateway.outgoing_payment(@company).processor, "#{@gateway.processor.class.name} is not nil"
      end

      should 'not accept receiver without instance client' do
        @company = FactoryGirl.create(:company)
        assert_nil @gateway.outgoing_payment(@company).processor, "#{@gateway.processor.class.name} is not nil"
      end

      should 'not accept receiver without filled balanced user id' do
        @company = FactoryGirl.create(:company_with_balanced)
        @company.instance_clients.first.update_attribute(:balanced_user_id, '')
        assert_nil @gateway.outgoing_payment(@company).processor, "#{@gateway.processor.class.name} is not nil"
      end

    end

  end

end
