module NewMarketplaceBuilder
  module Converters
    class WorkflowConverter < BaseConverter
      primary_key :workflow_type
      properties :name, :workflow_type, :events_metadata

      convert :workflow_steps, using: WorkflowStepConverter

      def scope
        Workflow.where(instance_id: @model.id)
      end
    end
  end
end
