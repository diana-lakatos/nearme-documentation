# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class WorkflowStepConverter < BaseConverter
      primary_key :associated_class, find_by: [:name, :associated_class]
      properties :name, :associated_class

      convert :workflow_alerts, using: WorkflowAlertConverter

      def scope
        @model.workflow_steps
      end
    end
  end
end
