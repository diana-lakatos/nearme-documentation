# frozen_string_literal: true
require 'test_helper'

class PaymentGateway::BraintreePaymentGatewayTest < ActiveSupport::TestCase
  setup do
    @braintree_processor = PaymentGateway::BraintreePaymentGateway.new
    @braintree_marketplace_processor = PaymentGateway::BraintreeMarketplacePaymentGateway.new
  end

  should 'properly translate options keys' do
    @payment = FactoryGirl.build(:payment)
    @payment.stubs(:payment_gateway).returns(@braintree_marketplace_processor)
    @payment.stubs(merchant_account: stub(verified?: true, custom_options: { merchant_account_id: 123 }))
    options = @payment.send(:payment_options)
    assert_equal @payment.send(:total_service_amount_cents), options[:service_fee_amount]
    assert_equal 123, options[:merchant_account_id]
    assert_equal options.size, options.size
  end

  should 'include environment in settings' do
    assert_equal :sandbox, @braintree_processor.settings[:environment]
  end

  should '#setup_api_on_initialize should return a ActiveMerchant BraintreeCustomGateway object' do
    assert_equal ActiveMerchant::Billing::BraintreeCustomGateway, @braintree_processor.class.active_merchant_class
  end

  should 'have a refund identification based on its id key' do
    charge = stub(payment: stub(authorization_token: '123'))
    assert_equal '123', @braintree_processor.refund_identification(charge)
  end

  should 'retry refund 10 times' do
    Braintree::Transaction.stubs(:find).returns(OpenStruct.new(status: 'settled', refund_ids: []))
    stub_active_merchant_interaction(success?: false, message: 'fail')

    @payment_gateway = FactoryGirl.create(:braintree_payment_gateway)
    @payment = FactoryGirl.create(:paid_payment, payment_method: @payment_gateway.payment_methods.first)
    @payment.refund!(@payment.total_amount_cents)
    assert_equal 10, @payment.refunds.count
  end
end
