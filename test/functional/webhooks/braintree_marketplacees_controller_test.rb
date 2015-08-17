require 'test_helper'

class Webhooks::BraintreeMarketplacesControllerTest < ActionController::TestCase

  context '#index' do
    setup do
      ActiveMerchant::Billing::BraintreeMarketplacePayments.any_instance.stubs(:onboard!).returns(OpenStruct.new(success?: true))

      @company = FactoryGirl.create(:company)
      @payment_gateway = FactoryGirl.create(:braintree_marketplace_payment_gateway)
      @braintree_marketplace_merchant_account = FactoryGirl.create(:braintree_marketplace_merchant_account, 
        merchantable: @company,
        payment_gateway: @payment_gateway
      )
      Braintree::WebhookNotification.stubs(:verify).returns(true)
    end

    context '#webhook' do
      should 'get request should verify braintree marketplace' do
        get :webhook, bt_challenge: '123'
        assert :success
      end

      should 'successful post request should change merchant account state to verified' do
        sample_notification = Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubMerchantAccountApproved,
          "id_#{@company.id}"
        )

        post :webhook, bt_signature: sample_notification[:bt_signature], bt_payload: sample_notification[:bt_payload]
        assert_equal 'verified', @braintree_marketplace_merchant_account.state
        assert :success
      end

      should 'unsuccessful post request should change merchant account state to failed' do
        sample_notification = Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined,
          "id_#{@company.id}"
        )

        post :webhook, bt_signature: sample_notification[:bt_signature], bt_payload: sample_notification[:bt_payload]
        assert_equal 'failed', @braintree_marketplace_merchant_account.reload.state
        assert :success
      end
    end
  end
end

