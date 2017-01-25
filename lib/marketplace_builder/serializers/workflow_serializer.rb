module MarketplaceBuilder
  module Serializers
    class WorkflowSerializer < BaseSerializer
      resource_name -> (w) { "workflows/#{w.name.underscore.parameterize('_')}" }

      properties :name, :workflow_type, :events_metadata

      serialize :workflow_steps, using: WorkflowStepSerializer

      def scope
        Workflow.where(instance_id: @model.id).all
      end
    end
  end
end
