# frozen_string_literal: true
require 'test_helper'

class ActiveMerchantResponseProcessorTest < ActiveSupport::TestCase
  setup do
    @payment_gateway = FactoryGirl.build(:stripe_payment_gateway)
  end

  should 'buiild successfull payment from success response' do
    attrs = ActiveMerchant::ResponseProcessor.new(response, @payment_gateway).payment_attributes
    payment = Payment.new(attrs)
    assert payment.paid?
    assert_equal 1, payment.charges.size
    assert payment.charges.first.success?
  end

  should 'build failed payment from failed response' do
    attrs = ActiveMerchant::ResponseProcessor.new(response(success: false), @payment_gateway).payment_attributes
    payment = Payment.new(attrs)
    assert payment.failed?
    assert_equal 1, payment.charges.size
    refute payment.charges.first.success?
  end

  def response(success: true, error_message: nil)
    OpenStruct.new(authorization: 'charge_token',
                   success?: success,
                   message: error_message,
                   params: {
                     balance_transaction: 'balance_token'
                   })
  end
end
