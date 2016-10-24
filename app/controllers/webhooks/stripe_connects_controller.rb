module Webhooks
  class StripeConnectsController < Webhooks::BaseWebhookController
    before_action :fetch_event

    def webhook
      case @event.type
      when 'account.updated' then account_updated
      when 'transfer.updated' then transfer_updated
      when 'transfer.created' then transfer_created
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
      update_transfer(event_transfer, @event.data.object.status)
    end

    def update_transfer(transfer, transfer_state)
      if transfer_state == 'paid'
        transfer.payout_attempts.last.payout_successful(@event)
      elsif %w(canceled failed).include?(transfer_state)
        transfer.payout_attempts.last.payout_failed(@event)
      end
    end

    def transfer_created
      return if transfer_scope.any?
      return if (payments = find_transfer_payments).blank?
      return if (company = payments.first.company).blank?
      return if payments.map(&:company_id).uniq.size != 1

      payment_transfer = @payment_gateway.payment_transfers.create!(
        company: company,
        payments: payments,
        payment_gateway_mode: @payment_gateway.mode,
        token: @event.data.object.id
      )

      update_transfer(payment_transfer, @event.data.object.status)
    end

    def find_transfer_payments
      return if transfer_charges.blank?

      charge_ids = transfer_charges.map(&:source).compact

      @payment_gateway.payments.where(external_transaction_id: charge_ids)
    end

    def event_transfer
      @transfer ||= transfer_scope.pending.first!
    end

    def transfer_scope
      @payment_gateway.payment_transfers.with_token(@event.data.object.id).where(payment_gateway_mode: @payment_gateway.mode)
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

    def transfer_transactions
      @transfer_transactions ||= @payment_gateway.find_transfer_transactions(
        @event.data.object.id, params[:user_id]
      ).try(:data)
    end

    def transfer_charges
      @transfer_charges ||= transfer_transactions.select { |t| t.type == 'charge' }
    end
  end
end
