module Webhooks
  class StripeConnectsController < Webhooks::BaseWebhookController
    before_filter :fetch_event

    def webhook
      case @event.type
      when 'account.updated' then account_updated
      when 'transfer.updated' then transfer_updated
      end
    ensure
      @payment_gateway.webhooks.create!(response: params.to_yaml)
      render nothing: true
    end

    private

    def account_updated
      merchant_account.skip_validation = true
      merchant_account.change_state_if_needed(account) { |state| workflow_for(state) }
      update_needed_fields
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
          "Missing fields: #{account.verification.fields_needed.join(', ')}"
        )
      end
    end

    def merchant_account
      @merchant_account ||= @payment_gateway.merchant_accounts.find_by!(
        internal_payment_gateway_account_id: @event.data.object.id
      )
    end

    def transfer_updated
      transfer_state = @event.data.object.status

      if transfer_state == 'paid'
        transfer.payout_attempts.last.payout_successful(@event)
      elsif %w(canceled failed).include?(transfer_state)
        transfer.payout_attempts.last.payout_failed(@event)
      end
    end

    def transfer
      @transfer ||= @payment_gateway.payment_transfers.pending.with_token(@event.data.object.id).first!
    end

    def payment_gateway_class
      PaymentGateway::StripeConnectPaymentGateway
    end

    def fetch_event
      @event = @payment_gateway.parse_webhook(params[:id], params[:user_id])
    end

    def account
      @account ||= @payment_gateway.retrieve_account(@event.data.object.id)
    end
  end
end
