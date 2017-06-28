# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class WorkflowAlertConverter < BaseConverter
      primary_key :name, find_by: [:name, :alert_type]
      properties :name, :alert_type, :recipient_type, :template_path, :delay, :subject,
                 :layout_path, :from, :reply_to, :cc, :bcc, :recipient, :from_type, :reply_to_type,
                 :endpoint, :request_type, :use_ssl, :payload_data, :headers,
                 :prevent_trigger_condition, :bcc_type, :enabled

      def scope
        @model.workflow_alerts
      end
    end
  end
end
