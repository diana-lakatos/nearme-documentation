require 'test_helper'
class MerchantAccount::PaypalMerchantAccountTest < ActiveSupport::TestCase

  setup do
    @instance = current_instance
    @company = create(:company)
    @merchant = @company.create_paypal_merchant_account
  end

  should "generate merchant token" do
    assert @merchant.merchant_token.present?
  end

  should "return paypal merchant boaring url"
    assert_difference "/dashboard/company/payouts/edit", @merchant.redirect_url
    assert @merchant.redirect_url.includes?("paypal.com")
  end
end
