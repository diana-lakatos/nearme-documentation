require 'test_helper'

class Webhooks::BraintreeMarketplacesControllerTest < ActionController::TestCase
  context '#index' do
    setup do
      ActiveMerchant::Billing::BraintreeCustomGateway.any_instance.stubs(:onboard!).returns(OpenStruct.new(success?: true))

      @company = FactoryGirl.create(:company)
      @payment_gateway = FactoryGirl.create(:braintree_marketplace_payment_gateway)
      @braintree_marketplace_merchant_account = FactoryGirl.create(:braintree_marketplace_merchant_account,
                                                                   merchantable: @company,
                                                                   payment_gateway: @payment_gateway,
                                                                   external_id: "id_#{@company.id}",
                                                                   state: 'pending')
      Braintree::WebhookNotification.stubs(:verify).returns(true)
    end

    context '#webhook' do
      should 'post request should verify braintree marketplace' do
        sample_notification = Braintree::WebhookTesting.sample_notification(
          'check',
          "id_#{@company.id}"
        )
        WorkflowStepJob.expects(:perform).never
        post :webhook, bt_signature: sample_notification[:bt_signature], bt_payload: sample_notification[:bt_payload]
        assert :success
      end

      should 'successful post request should change merchant account state to verified' do
        sample_notification = Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubMerchantAccountApproved,
          "id_#{@company.id}"
        )

        WorkflowStepJob.expects(:perform).with do |klass, merchant_account_id|
          klass == WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved && merchant_account_id == @braintree_marketplace_merchant_account.id
        end

        assert_difference 'Webhook.count' do
          post :webhook, bt_signature: sample_notification[:bt_signature], bt_payload: sample_notification[:bt_payload]
        end
        assert_equal 'verified', @braintree_marketplace_merchant_account.reload.state
        assert :success
      end

      should 'unsuccessful post request should change merchant account state to failed' do
        sample_notification = Braintree::WebhookTesting.sample_notification(
          Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined,
          "id_#{@company.id}"
        )

        WorkflowStepJob.expects(:perform).with do |klass, merchant_account_id|
          klass == WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined && merchant_account_id == @braintree_marketplace_merchant_account.id
        end

        assert_difference 'Webhook.count' do
          post :webhook, bt_signature: sample_notification[:bt_signature], bt_payload: sample_notification[:bt_payload]
        end
        assert_equal 'failed', @braintree_marketplace_merchant_account.reload.state
        assert :success
      end

      context 'disbursement' do
        setup do
          Braintree::MerchantAccount.any_instance.stubs(:id).returns("id_#{@company.id}")
        end

        should 'handle Disbursement webhook if succeeded' do
          sample_notification = Braintree::WebhookTesting.sample_notification(
            Braintree::WebhookNotification::Kind::Disbursement,
            'disbursement_id'
          )
          WorkflowStepJob.expects(:perform).with do |klass, merchant_account_id, hash|
            klass == WorkflowStep::PaymentGatewayWorkflow::DisbursementSucceeded && merchant_account_id == @braintree_marketplace_merchant_account.id && hash == {
              'amount' => 100.0,
              'transaction_ids' => %w(afv56j kj8hjk),
              'disbursement_date' => Date.new(2014, 2, 10)
            }
          end

          assert_difference 'Webhook.count' do
            post :webhook, bt_signature: sample_notification[:bt_signature], bt_payload: sample_notification[:bt_payload]
          end
          assert :success
        end

        should 'handle Disbursement webhook if exception occurred' do
          sample_notification = Braintree::WebhookTesting.sample_notification(
            Braintree::WebhookNotification::Kind::DisbursementException,
            'disbursement_id'
          )
          WorkflowStepJob.expects(:perform).with do |klass, merchant_account_id, hash|
            klass == WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed && merchant_account_id == @braintree_marketplace_merchant_account.id && hash == {
              'exception_message' => 'bank_rejected',
              'follow_up_action' => 'update_funding_information',
              'amount' => 100.0,
              'transaction_ids' => %w(afv56j kj8hjk),
              'disbursement_date' => Date.new(2014, 2, 10)
            }
          end

          assert_difference 'Webhook.count' do
            post :webhook, bt_signature: sample_notification[:bt_signature], bt_payload: sample_notification[:bt_payload]
          end
          assert :success
        end
      end
    end
  end
end
