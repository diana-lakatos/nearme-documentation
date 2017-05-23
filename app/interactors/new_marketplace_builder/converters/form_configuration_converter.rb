# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class FormConfigurationConverter < BaseConverter
      primary_key :name
      properties :name, :base_form, :configuration
      property :body
      property :workflow_steps

      def body(form_configuration)
        form_configuration.liquid_body
      end

      def set_body(form_configuration, value)
        form_configuration.liquid_body = value
      end

      def workflow_steps(form_configuration)
        form_configuration.workflow_steps.map(&:name)
      end

      def set_workflow_steps(form_configuration, workflow_step_names)
        workflow_steps = WorkflowStep.where(name: workflow_step_names)
        form_configuration.workflow_steps = workflow_steps
      end

      def scope
        FormConfiguration.where(instance_id: @model.id)
      end
    end
  end
end
