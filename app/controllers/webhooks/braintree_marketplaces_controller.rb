class Webhooks::BraintreeMarketplacesController < Webhooks::BaseWebhookController

  def webhook
    if request.get? && params[:bt_challenge].present?
      render text: @payment_gateway.verify_webhook(params[:bt_challenge])
    elsif request.post? && (notification = @payment_gateway.parse_webhook(params[:bt_signature], params[:bt_payload])).present?

      case notification.kind
        # notification concerns sub merchant account, which is triggered 1-2m after host fills payout information form
      when Braintree::WebhookNotification::Kind::SubMerchantAccountApproved, Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined
        merchant_account = MerchantAccount.find_by!(internal_payment_gateway_account_id: notification.merchant_account.id, payment_gateway: @payment_gateway, test: @payment_gateway.test_mode?)
        company = merchant_account.merchantable
        merchant_account.skip_validation = true
        if notification.kind == Braintree::WebhookNotification::Kind::SubMerchantAccountApproved
          merchant_account.verify!
          WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, merchant_account.id)
        else
          merchant_account.failure!
          WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined, merchant_account.id, notification.try(:errors).try(:map, &:message).try(:join, ', '))
        end
        # notification concerns payment transfer - we are notified that it succeded or it failed. It's crucial to handle DisbursementException, otherwise
        # there is no other way for us to know whether payout failed and host needs to update bank account information
      when Braintree::WebhookNotification::Kind::Disbursement, Braintree::WebhookNotification::Kind::DisbursementException
        merchant_account = MerchantAccount.find_by!(internal_payment_gateway_account_id: notification.disbursement.merchant_account.id, payment_gateway: @payment_gateway, test: @payment_gateway.test_mode?)
        company = merchant_account.merchantable
        if notification.disbursement.success
          # this actually means that disbursement has been scheduled, it still can fail
          WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::DisbursementSucceeded, merchant_account.id, {
            'amount' => notification.disbursement.amount,
            'disbursement_date' => notification.disbursement.disbursement_date,
            'transaction_ids' => notification.disbursement.transaction_ids
          })
        else
          PaymentTransfer.where(id: company.payments.where(external_transaction_id: notification.disbursement.transaction_ids).uniq.pluck(:payment_transfer_id)).update_all(failed_at: Time.zone.now)
          WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed, merchant_account.id, {
            'exception_message' => notification.disbursement.exception_message,
            'follow_up_action' => notification.disbursement.follow_up_action,
            'amount' => notification.disbursement.amount,
            'disbursement_date' => notification.disbursement.disbursement_date,
            'transaction_ids' => notification.disbursement.transaction_ids
          })
        end
      end
      merchant_account.try(:webhooks).try(:create!, response: notification.to_yaml)
      render nothing: true
    end
  end

  protected

  def payment_gateway_class
    PaymentGateway::BraintreeMarketplacePaymentGateway
  end

end
