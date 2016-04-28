require 'test_helper'

class MerchantAccountTest < ActiveSupport::TestCase

  context 'payment gateway with separate test/live merchant accounts' do
    setup do
      MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:onboard!)
    end

    should 'have separate test account for test mode' do
      Instance.any_instance.stubs(test_mode?: true)
      merchant_account = FactoryGirl.create(:stripe_connect_merchant_account)
      assert_equal merchant_account, merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
      Instance.any_instance.stubs(test_mode?: false)
      assert_nil merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
      Instance.any_instance.stubs(test_mode?: true)
      assert_equal merchant_account, merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
    end

    should 'have separate account for live mode' do
      Instance.any_instance.stubs(test_mode?: false)
      merchant_account = FactoryGirl.create(:stripe_connect_merchant_account)
      assert_equal merchant_account, merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
      Instance.any_instance.stubs(test_mode?: true)
      assert_nil merchant_account.merchantable.reload.merchant_accounts.mode_scope.first
    end
  end
end
