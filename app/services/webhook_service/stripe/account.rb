# frozen_string_literal: true
module WebhookService
  module Stripe
    class Account < WebhookService::Stripe::Event
      ALLOWED_EVENTS = %w{updated}
      ACCOUNT_WORKFLOW_MAP = {
        verified: WorkflowStep::PaymentGatewayWorkflow::MerchantAccountApproved,
        failed: WorkflowStep::PaymentGatewayWorkflow::MerchantAccountDeclined,
        incomplete: WorkflowStep::PaymentGatewayWorkflow::MerchantAccountPending
      }


      def parse_event!
        return false unless ALLOWED_EVENTS.map {|e| "account." + e }.include?(event.type)
        # Stripe can send account.updated for main MPO account
        # in that case user_id params is not set, we want to ignore those webhooks.
        return false if merchant_account.blank?

        account_updated
      end

      private

      def account
        if fetch_object?
          @account ||= payment_gateway.retrieve_account(event.data.object.id)
        else
          @account ||= Payment::Gateway::Response::Stripe::Account.new(event.data.object)
        end
      end

      def account_updated
        merchant_account.skip_validation = true
        merchant_account.update_attributes(account.attributes)
        merchant_account.change_state_if_needed(account) do |state|
          send_merchant_workflow(ACCOUNT_WORKFLOW_MAP[state.to_sym])
        end
        true
      end

      def send_merchant_workflow(workflow_type_class)
        WorkflowStepJob.perform(workflow_type_class, merchant_account.id)
      end
    end
  end
end
