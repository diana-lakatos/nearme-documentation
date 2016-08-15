class Webhooks::StripeConnectsController < Webhooks::BaseWebhookController

  def webhook
    if request.post?
      begin
        event = @payment_gateway.parse_webhook(params[:id])
        case event.type
        when 'account.updated'
          merchant_account = MerchantAccount::StripeConnectMerchantAccount.find_by(internal_payment_gateway_account_id: params[:user_id])
          account = @payment_gateway.retrieve_account(event.data.object.id)
          merchant_account.skip_validation = true
          merchant_account.change_state_if_needed(account) do |new_state|
            case new_state
            when 'verified'
              WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved, merchant_account.id)
            when 'failed'
              WorkflowStepJob.perform(WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined, merchant_account.id, "Missing fields: #{account.verification.fields_needed.join(', ')}")
            end
          end
          if account.verification.fields_needed.present?
            merchant_account.update_column :data, merchant_account.data.merge(fields_needed: account.verification.fields_needed)
          end
        when 'transfer.paid'
          transfer = @payment_gateway.payment_transfers.pending.with_token(event.data.object.id).first
          if transfer.pending?
            transfer.payout_attempts.last.payout_successful(event)
          end
        when 'transfer.failed'
          transfer = @payment_gateway.payment_transfers.pending.with_token(event.data.object.id).first
          if transfer.pending?
            transfer.payout_attempts.last.payout_failed(event)
          end
        end
      ensure
        if merchant_account
          merchant_account.webhooks.create!(response: params.to_yaml)
        else
          @payment_gateway.webhooks.create!(response: params.to_yaml)
        end

      end
    end
  ensure
    render nothing: true
  end

  protected

  def payment_gateway_class
    PaymentGateway::StripeConnectPaymentGateway
  end

end

