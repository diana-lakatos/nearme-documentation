# frozen_string_literal: true
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
    process_error('Webhook not found') && return if event.blank?
    process_error("Webhook type #{event.kind} not allowed") && return unless ALLOWED_WEBHOOKS.include?(event.kind)
    process_error('Mode mismatch') && return if payment_gateway_mode != payment_gateway.mode

    increment!(:retry_count)

    success = send(ALLOWED_WEBHOOKS[event.kind])
    success ? archive : mark_as_failed

  rescue => e
    process_error(e, should_raise: true)
  end

  def webhook_test
    true
  end

  def event
    @event ||= payment_gateway.parse_webhook(params[:bt_signature], params[:bt_payload])
  end

  def merchant_account_external_id
    (event.merchant_account || event.disbursement.try(:merchant_account)).try(:id)
  end

  def set_merchant_account
    return if merchant_account_external_id.blank?
    self.merchant_account = MerchantAccount.find_by!(external_id: merchant_account_external_id, payment_gateway: payment_gateway, test: payment_gateway.test_mode?)
  end

  def merchant_account_approve
    return true if merchant_account.try(:verified?)

    merchant_account.skip_validation = true
    merchant_account.verify!
    WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, merchant_account.id)
    true
  end

  def merchant_account_decline
    merchant_account.skip_validation = true
    merchant_account.failure!
    WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined, merchant_account.id, event.try(:errors).try(:map, &:message).try(:join, ', '))
    true
  end

  def dusbursement_update
    if event.disbursement.success
      # this actually means that disbursement has been scheduled, it still can fail
      WorkflowStepJob.perform(
        WorkflowStep::PaymentGatewayWorkflow::DisbursementSucceeded,
        merchant_account.id,
        'amount' => event.disbursement.amount,
        'disbursement_date' => event.disbursement.disbursement_date,
        'transaction_ids' => event.disbursement.transaction_ids
      )
      mark_transfers_as_transferred
    else
      mark_transfers_as_failed
      WorkflowStepJob.perform(
        WorkflowStep::PaymentGatewayWorkflow::DisbursementFailed,
        merchant_account.id,
        'exception_message' => event.disbursement.exception_message,
        'follow_up_action' => event.disbursement.follow_up_action,
        'amount' => event.disbursement.amount,
        'disbursement_date' => event.disbursement.disbursement_date,
        'transaction_ids' => event.disbursement.transaction_ids
      )
    end
    true
  end

  def mark_transfers_as_failed
    disbursement_transfers.each { |t| t.payout_attempts.last.payout_failed(event) }
  end

  def mark_transfers_as_transferred
    disbursement_transfers.each { |t| t.payout_attempts.last.payout_successful(event) }
  end

  def disbursement_transfers
    PaymentTransfer.where(id: event_transfers_ids)
  end

  def event_transfers_ids
    merchant_account.payments.where(external_id: event.disbursement.transaction_ids).uniq.pluck(:payment_transfer_id)
  end

  def webhook_type
    event.kind
  end

  def livemode?
    response.match('environment: :production')
  end
end
