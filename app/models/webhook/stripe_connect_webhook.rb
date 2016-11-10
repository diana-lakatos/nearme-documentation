# frozen_string_literal: true
class Webhook::StripeConnectWebhook < Webhook
  before_create :set_merchant_account

  ALLOWED_WEBHOOKS = {
    account_updated: ['account.updated'],
    transfer_created: ['transfer.created'],
    transfer_updated: ['transfer.paid', 'transfer.failed', 'transfer.updated']
  }.freeze

  def process!
    process_error('Webhook not found') && return if event.blank?
    process_error("Webhook type #{event.type} not allowed") && return unless ALLOWED_WEBHOOKS.values.flatten.include?(event.type)
    process_error('Mode mismatch') && return  if payment_gateway_mode != payment_gateway.mode

    increment!(:retry_count)

    success = send(event_handler)
    success ? archive : mark_as_failed

  rescue => e
    process_error(e, should_raise: true)
  end

  def webhook_type
    @webhook_type ||= params['type']
  end

  def event_handler
    ALLOWED_WEBHOOKS.select { |_k, v| v.include?(event.type) }.keys.first
  end

  def livemode?
    !!params['livemode']
  end

  def event
    @event ||= payment_gateway.parse_webhook(params[:id], params[:user_id])
  end

  def account_updated
    merchant_account.skip_validation = true
    merchant_account.change_state_if_needed(account) { |state| workflow_for(state) }
    update_needed_fields
    true
  end

  def update_needed_fields
    return unless account.verification.fields_needed.present?
    merchant_account.update_column :data, merchant_account.data.merge(fields_needed: account.verification.fields_needed)
  end

  def workflow_for(state)
    case state
    when 'verified'
      WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, merchant_account.id)
    when 'failed'
      WorkflowStepJob.perform(
        WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined,
        merchant_account.id,
        account.legal_entity.verification.details.presence || "Missing fields: #{account.verification.fields_needed.join(', ')}"
      )
    end
  end

  def merchant_account
    @merchant_account ||= super || payment_gateway.merchant_accounts.find_by!(
      external_id: params[:user_id] || event.data.object.id
    )
  end

  def transfer_updated
    update_transfer(params_transfer, event.data.object.status)
  end

  def transfer_created
    return if transfer_scope.any?
    return if (payments = find_transfer_payments).blank?
    return if (company = payments.first.company).blank?
    return if payments.map(&:company_id).uniq.size != 1

    payment_transfer = payment_gateway.payment_transfers.create!(
      company: company,
      payments: payments,
      payment_gateway_mode: payment_gateway.mode,
      token: event.data.object.id,
      merchant_account: merchant_account
    )

    update_transfer(payment_transfer, event.data.object.status)
  end

  def update_transfer(transfer, transfer_state)
    if transfer_state == 'paid'
      transfer.payout_attempts.last.payout_successful(params)
    elsif %w(canceled failed).include?(transfer_state)
      transfer.payout_attempts.last.payout_failed(params)
    end
  end

  def find_transfer_payments
    return if transfer_charges.blank?

    charge_ids = transfer_charges.map(&:source).compact

    payment_gateway.payments.where(external_id: charge_ids)
  end

  def params_transfer
    @transfer ||= transfer_scope.pending.first!
  end

  def transfer_scope
    payment_gateway.payment_transfers.with_token(event.data.object.id).where(payment_gateway_mode: payment_gateway.mode)
  end

  def account
    @account ||= payment_gateway.retrieve_account(event.data.object.id)
  end

  def transfer_transactions
    @transfer_transactions ||= payment_gateway.find_transfer_transactions(
      event.data.object.id, params[:user_id]
    ).try(:data)
  end

  def transfer_charges
    @transfer_charges ||= transfer_transactions.select { |t| t.type == 'charge' }
  end

  def set_merchant_account
    return if params[:user_id].blank?

    self.merchant_account = payment_gateway.merchant_accounts.find_by(external_id: params[:user_id])
  end
end
