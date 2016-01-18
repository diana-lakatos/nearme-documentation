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
    charge = stub(payment: stub(payable: stub(billing_authorization: stub(token: '123'))))
    assert_equal "123", @braintree_processor.refund_identification(charge)
  end
end
