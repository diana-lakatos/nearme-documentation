require 'test_helper'

class MerchantAccountTest < ActiveSupport::TestCase

  context 'payment gateway with single test/live merchant account' do
    should 'have single merchant account for test and live modes' do
      Instance.any_instance.stubs(test_mode?: true)
      ActiveMerchant::Billing::BraintreeMarketplacePayments.any_instance.stubs(:onboard!).returns(OpenStruct.new(success?: true))
      merchant_account = FactoryGirl.create(:braintree_marketplace_merchant_account)
      assert_equal merchant_account.merchantable.reload.braintree_marketplace_merchant_account, merchant_account
      Instance.any_instance.stubs(test_mode?: false)
      assert_equal merchant_account.merchantable.reload.braintree_marketplace_merchant_account, merchant_account
    end
  end

  context 'payment gateway with separate test/live merchant accounts' do
    setup do
      MerchantAccount::StripeConnectMerchantAccount.any_instance.stubs(:onboard!)
    end

    should 'have separate test account for test mode' do
      Instance.any_instance.stubs(test_mode?: true)
      merchant_account = FactoryGirl.create(:stripe_connect_merchant_account)
      assert_equal merchant_account, merchant_account.merchantable.reload.stripe_connect_merchant_account
      Instance.any_instance.stubs(test_mode?: false)
      assert_nil merchant_account.merchantable.reload.stripe_connect_merchant_account
      Instance.any_instance.stubs(test_mode?: true)
      assert_equal merchant_account, merchant_account.merchantable.reload.stripe_connect_merchant_account
    end

    should 'have separate account for live mode' do
      Instance.any_instance.stubs(test_mode?: false)
      merchant_account = FactoryGirl.create(:stripe_connect_merchant_account)
      assert_equal merchant_account, merchant_account.merchantable.reload.stripe_connect_merchant_account
      Instance.any_instance.stubs(test_mode?: true)
      assert_nil merchant_account.merchantable.reload.stripe_connect_merchant_account
    end

    should 'change account when force_mode applied' do
      Instance.any_instance.stubs(test_mode?: true)
      test_merchant_account = FactoryGirl.create(:stripe_connect_merchant_account)

      Instance.any_instance.stubs(test_mode?: false)
      live_merchant_account = FactoryGirl.create(:stripe_connect_merchant_account)

      PaymentGateway::StripeConnectPaymentGateway.any_instance.stubs(test_mode?: true)
      assert_equal test_merchant_account, test_merchant_account.merchantable.reload.stripe_connect_merchant_account
      assert_not Instance.find(test_merchant_account.instance_id).test_mode?
    end
  end
end
