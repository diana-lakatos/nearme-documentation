module MarketplaceBuilder
  module Serializers
    class WorkflowAlertSerializer < BaseSerializer
      properties :name, :alert_type, :recipient_type, :template_path, :delay, :subject, :layout_path, :from, :reply_to

      def scope
        @model.workflow_alerts
      end
    end
  end
end
