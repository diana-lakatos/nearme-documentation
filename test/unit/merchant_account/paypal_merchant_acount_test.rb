require 'test_helper'
class MerchantAccount::PaypalMerchantAccountTest < ActiveSupport::TestCase

  setup do
    @instance = current_instance
    @company = create(:company)
    @payout_gateway = FactoryGirl.create :paypal_express_payment_gateway
    @merchant = @company.create_paypal_merchant_account(payment_gateway: @payout_gateway)
  end

  should "generate merchant token" do
    assert @merchant.merchant_token.present?
  end

  should "return paypal merchant boaring url" do
    assert @merchant.boarding_url.include?("paypal.com")
  end
end
