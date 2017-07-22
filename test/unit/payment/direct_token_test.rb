# frozen_string_literal: true
require 'test_helper'

class Payment::DirectTokenTest < ActiveSupport::TestCase

  should 'get token with response form Stripe' do
    stripe_token = 'tok_1234'
    card_token = 'card_1234'
    cus_token = 'cus_1234'

    @payment_gateway = FactoryGirl.create :stripe_connect_payment_gateway, config: { "settings" => { "charge_type" => 'direct' }}
    @payment = FactoryGirl.build(:pending_payment, payment_method: @payment_gateway.payment_methods.credit_card.first)
    @payment.stubs(:merchant_id).returns('merchant_id')
    @payment.payment_source.stubs(:customer_id).returns(cus_token)
    @payment.payment_source.stubs(:to_active_merchant).returns(card_token)

    stub_request(:post, "https://api.stripe.com/v1/tokens").
      with(:body => {card: card_token, customer: cus_token }).
      to_return(:status => 200, :body => ({ id: stripe_token}).to_json)

    assert_equal stripe_token, @payment.direct_token
  end

  should 'build card options' do
    card_token = 'zyx'
    payment_source = CreditCard.new
    payment_source.stubs(:to_active_merchant).returns(token: card_token)
    assert_equal ({ card: { token: card_token}}), options(payment_source)
  end

  should 'build bank_account options' do
    payment_source = BankAccount.new
    bank_token = 'xyz'
    payment_source.stubs(:customer_id).returns('customer_id')
    payment_source.stubs(:to_active_merchant).returns(token: bank_token)
    assert_equal ({ bank_account: { token: bank_token}}), options(payment_source)
  end

  def options(payment_source)
    Payment::DirectToken.new(OpenStruct.new(payment_source: payment_source)).options
  end
end
