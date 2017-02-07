# frozen_string_literal: true
require 'test_helper'

class PaymentDecoratorTest < Draper::TestCase
  test '#default_payment_source' do
    payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
    instance_client = FactoryGirl.build(:instance_client, response: nil, payment_gateway: payment_gateway)
    payment_method = FactoryGirl.create(:credit_card_payment_method, payment_gateway: payment_gateway)
    cc = FactoryGirl.create(:credit_card, instance_client: instance_client, payment_gateway_id: payment_gateway.id)
    payment_method.payment_sources << cc
    payment = FactoryGirl.create(:pending_payment, payment_gateway: payment_gateway)
    payment_decorator = PaymentDecorator.new(payment)

    assert_equal payment_decorator.default_payment_source(payment_method), ['**** **** **** ', cc.id]
  end
end
