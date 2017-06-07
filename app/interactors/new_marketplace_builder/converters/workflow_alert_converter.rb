module NewMarketplaceBuilder
  module Converters
    class WorkflowAlertConverter < BaseConverter
      primary_key :template_path, find_by: [:template_path, :recipient_type]
      properties :name, :alert_type, :recipient_type, :template_path, :delay, :subject, :layout_path, :from, :reply_to

      def scope
        @model.workflow_alerts
      end
    end
  end
end
