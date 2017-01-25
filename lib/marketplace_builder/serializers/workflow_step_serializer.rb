module MarketplaceBuilder
  module Serializers
    class WorkflowStepSerializer < BaseSerializer
      properties :name, :associated_class

      serialize :workflow_alerts, using: WorkflowAlertSerializer

      def scope
        @model.workflow_steps
      end
    end
  end
end
