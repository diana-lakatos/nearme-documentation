module WebhookService
  module Stripe
    class Account < WebhookService::Stripe::Event
      ALLOWED_EVENTS = %w{updated}

      def parse_event!
        return false unless ALLOWED_EVENTS.map {|e| "account." + e }.include?(event.type)
        # Stripe can send account.updated for main MPO account
        # in that case user_id params is not set, we want to ignore those webhooks.
        return false if merchant_account.blank?

        account_updated
      end

      private

      def account
        @account ||= payment_gateway.retrieve_account(event.data.object.id)
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
        when 'incomplete'
          WorkflowStepJob.perform(
            WorkflowStep::PaymentGatewayWorkflow::MerchantAccountPending,
            merchant_account.id
            )
        end
      end
    end
  end
end
