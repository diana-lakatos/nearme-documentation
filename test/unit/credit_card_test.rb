# frozen_string_literal: true
require 'test_helper'
require 'stripe'

class CreditCardTest < ActiveSupport::TestCase
  context 'save' do
    setup do
      @instance_client = FactoryGirl.build(:instance_client, response: nil)
    end

    should 'not persist card if not valid' do
      card = FactoryGirl.build(:invalid_credit_card_attributes, response: nil)
      refute card.save
      refute card.persisted?
      assert_equal card.errors[:base][0], I18n.t('buy_sell_market.checkout.invalid_cc')
    end

    should 'persist card if valid and successful response with correct mode' do
      ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:store).returns(am_success_response(customer_params))
      Instance.any_instance.stubs(:test_mode?).returns(false)
      card = FactoryGirl.build(:credit_card_attributes, response: nil, instance_client: @instance_client)
      assert card.save
      assert card.success?
      assert_equal customer_params['default_source'], card.token
      assert_equal false, card.test_mode
    end

    should 'persist card if valid and successful multi response with correct mode' do
      ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:store).returns(am_success_multi_response)
      card = FactoryGirl.build(:credit_card_attributes, response: nil, instance_client: @instance_client)
      assert card.save
      assert card.success?
      assert_equal customer_params['default_source'], card.token
      assert_equal customer_params['id'], card.instance_client.customer_id
      assert_equal true, card.test_mode
    end

    should 'find instance_client when deleted' do
      ActiveMerchant::Billing::StripeGateway.any_instance.stubs(:store).returns(am_success_response(customer_params))
      Instance.any_instance.stubs(:test_mode?).returns(false)
      card = FactoryGirl.build(:credit_card_attributes, response: nil, instance_client: @instance_client, payment_gateway: @instance_client.payment_gateway)
      assert card.save
      card.payment_gateway.destroy
      card.reload
      assert card.payment_gateway.deleted?
      assert card.instance_client.deleted?
    end
  end

  private

  def am_success_response(params)
    ActiveMerchant::Billing::Response.new(true, 'All good', params)
  end

  def am_success_multi_response
    multi_response = ActiveMerchant::Billing::MultiResponse.new.tap do |r|
      r.process { am_success_response(customer_params) }
    end
  end

  def card_params
    {
      'id' => 'card_7uld6VoLOe5wlE',
      'object' => 'card',
      'address_city' => nil,
      'address_country' => nil,
      'address_line1' => nil,
      'address_line1_check' => nil,
      'address_line2' => nil,
      'address_state' => nil,
      'address_zip' => nil,
      'address_zip_check' => nil,
      'brand' => 'Visa',
      'country' => 'US',
      'customer' => 'cus_7ulSIgmS0e7cXN',
      'cvc_check' => 'pass',
      'dynamic_last4' => nil,
      'exp_month' => 1,
      'exp_year' => 2017,
      'fingerprint' => 'kbCbhEoOBuw6SBa7',
      'funding' => 'unknown',
      'last4' => '1111',
      'metadata' => {},
      'name' => 'Tomasz Last',
      'tokenization_method' => nil
    }
  end

  def customer_params
    {
      'id' => 'cus_7ulSIgmS0e7cXN',
      'object' => 'customer',
      'account_balance' => 0,
      'created' => 1_455_579_546,
      'currency' => nil,
      'default_source' => 'card_7ulSqAoTkgIuqL',
      'delinquent' => false,
      'description' => nil,
      'discount' => nil,
      'email' => 'lemkowski@gmail.com',
      'livemode' => false,
      'metadata' => {},
      'shipping' => nil,
      'sources' => {
        'object' => 'list',
        'data' => [
          {
            'id' => 'card_7ulSqAoTkgIuqL',
            'object' => 'card',
            'address_city' => nil,
            'address_country' => nil,
            'address_line1' => nil,
            'address_line1_check' => nil,
            'address_line2' => nil,
            'address_state' => nil,
            'address_zip' => nil,
            'address_zip_check' => nil,
            'brand' => 'Visa',
            'country' => 'US',
            'customer' => 'cus_7ulSIgmS0e7cXN',
            'cvc_check' => 'pass',
            'dynamic_last4' => nil,
            'exp_month' => 1,
            'exp_year' => 2017,
            'fingerprint' => 'kbCbhEoOBuw6SBa7',
            'funding' => 'unknown',
            'last4' => '1111',
            'metadata' => {},
            'name' => 'Tomasz Last',
            'tokenization_method' => nil
          }
        ],
        'has_more' => false,
        'total_count' => 1,
        'url' => '/v1/customers/cus_7ulSIgmS0e7cXN/sources'
      },
      'subscriptions' => {
        'object' => 'list',
        'data' => [],
        'has_more' => false,
        'total_count' => 0,
        'url' => '/v1/customers/cus_7ulSIgmS0e7cXN/subscriptions'
      }
    }
  end
end
