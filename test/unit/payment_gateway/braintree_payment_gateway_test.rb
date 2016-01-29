require 'test_helper'

class PaymentGateway::BraintreePaymentGatewayTest < ActiveSupport::TestCase

  setup do
    @braintree_processor = PaymentGateway::BraintreePaymentGateway.new
  end

  should "include environment in settings" do
    assert_equal :sandbox, @braintree_processor.settings[:environment]
  end

  should "#setup_api_on_initialize should return a ActiveMerchant BraintreeBlueGateway object" do
    assert_equal ActiveMerchant::Billing::BraintreeBlueGateway, @braintree_processor.class.active_merchant_class
  end

  should "have a refund identification based on its id key" do
    charge = stub(payment: stub(authorization_token: '123'))
    assert_equal "123", @braintree_processor.refund_identification(charge)
  end

  should "retry refund 10 times" do
    Braintree::Transaction.stubs(:find).returns(OpenStruct.new({status: 'settled'}))
    stub_active_merchant_interaction({success?: false, message: "fail"})

    @payment_gateway = FactoryGirl.create(:braintree_payment_gateway)
    @payment = FactoryGirl.create(:paid_payment, payment_method: @payment_gateway.payment_methods.first)
    @payment.refund!
    assert_equal 10, @payment.refunds.count
  end
end
