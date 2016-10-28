class Webhook::BraintreeMarketplaceWebhook < Webhook
  before_create :set_merchant_account

  ALLOWED_WEBHOOKS = {
    Braintree::WebhookNotification::Kind::SubMerchantAccountApproved => 'merchant_account_approve',
    Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined => 'merchant_account_decline',
    Braintree::WebhookNotification::Kind::Disbursement => 'dusbursement_update',
    Braintree::WebhookNotification::Kind::DisbursementException => 'dusbursement_update',
    'check' => 'webhook_test'
  }.freeze

  def process!
    increment!(:retry_count)

    raise 'Webhook not found' if notification.blank?
    raise "Webhook type #{notification.kind} not allowed" unless ALLOWED_WEBHOOKS.keys.include?(notification.kind)

    success = send(ALLOWED_WEBHOOKS[notification.kind])
    true
    success ? archive : mark_as_failed
  rescue => e
    self.error = e.to_s
    mark_as_failed
    raise e
  end

  def webhook_test
    true
  end

  def notification
    @notification ||= payment_gateway.parse_webhook(params[:bt_signature], params[:bt_payload])
  end

  def merchant_account_external_id
    (notification.merchant_account || notification.disbursement.try(:merchant_account)).try(:id)
  end

  def set_merchant_account
    return if merchant_account_external_id.blank?
    self.merchant_account = MerchantAccount.find_by!(internal_payment_gateway_account_id: merchant_account_external_id, payment_gateway: payment_gateway, test: payment_gateway.test_mode?)
  end

  def merchant_account_approve
    merchant_account.skip_validation = true
    merchant_account.verify!
    WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, merchant_account.id)
    true
  end

  def merchant_account_decline
    merchant_account.skip_validation = true
    merchant_account.failure!
    WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined, merchant_account.id, notification.try(:errors).try(:map, &:message).try(:join, ', '))
    true
  end

  def dusbursement_update
    if notification.disbursement.success
      # this actually means that disbursement has been scheduled, it still can fail
      WorkflowStepJob.perform(
        WorkflowStep::PaymentGatewayWorkflow::DisbursementSucceeded,
        merchant_account.id,
        'amount' => notification.disbursement.amount,
        'disbursement_date' => notification.disbursement.disbursement_date,
        'transaction_ids' => notification.disbursement.transaction_ids
      )
    else
      mark_transfers_as_failed
      WorkflowStepJob.perform(
        WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed,
        merchant_account.id,
        'exception_message' => notification.disbursement.exception_message,
        'follow_up_action' => notification.disbursement.follow_up_action,
        'amount' => notification.disbursement.amount,
        'disbursement_date' => notification.disbursement.disbursement_date,
        'transaction_ids' => notification.disbursement.transaction_ids
      )
    end
    true
  end

  def mark_transfers_as_failed
    PaymentTransfer.where(id: notification_transfers_ids).update_all(failed_at: Time.zone.now)
  end

  def notification_transfers_ids
    merchant_account.payments.where(external_transaction_id: notification.disbursement.transaction_ids).uniq.pluck(:payment_transfer_id)
  end

  def webhook_type
    notification.kind
  end

  def livemode?
    response.match('environment: :production')
  end
end
