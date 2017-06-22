# frozen_string_literal: true
require 'test_helper'
require 'stripe'

class BankAccountTest < ActiveSupport::TestCase
  setup do
    @payment_gateway = FactoryGirl.create(:stripe_connect_payment_gateway)
    @ach_payment_method = @payment_gateway.payment_methods.ach.last
  end

  context 'instance client' do
    setup do
      @instance_client = FactoryGirl.create(:instance_client, response: nil, payment_gateway: @payment_gateway)
      @bank_account = BankAccount.new(payment_method: @ach_payment_method, payer: @instance_client.client)
    end

    should 'be returned when exists within PaymentGateway' do
      InstanceClient.any_instance.stubs(:find).returns(true)
      assert_equal @instance_client, @bank_account.instance_client
    end

    should 'build new Instance Client when not found' do
      assert_equal InstanceClient, @bank_account.instance_client.class
      assert @bank_account.instance_client.new_record?
    end
  end

  should 'set live mode properly' do
    Instance.any_instance.stubs(:test_mode?).returns(false)
    bank_account = BankAccount.new(payment_method: @ach_payment_method)
    bank_account.valid?
    refute bank_account.test_mode?
  end
end
