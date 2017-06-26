# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class FormConfigurationConverter < BaseConverter
      primary_key :name
      properties :name, :base_form, :configuration
      property :body
      property :workflow_steps
      property :authorization_policies

      def body(form_configuration)
        form_configuration.liquid_body
      end

      def set_body(form_configuration, value)
        form_configuration.liquid_body = value
      end

      def workflow_steps(form_configuration)
        form_configuration.workflow_steps.pluck(:name)
      end

      def set_workflow_steps(form_configuration, workflow_step_names)
        form_configuration.workflow_step_ids = WorkflowStep.where(name: workflow_step_names).pluck(:id)
      end

      def authorization_policies(form_configuration)
        form_configuration.authorization_policies.pluck(:name)
      end

      def set_authorization_policies(form_configuration, authorization_policies_names)
        form_configuration.authorization_policy_ids = AuthorizationPolicy.where(name: authorization_policies_names).pluck(:id)
      end

      def scope
        FormConfiguration.where(instance_id: @model.id)
      end
    end
  end
end
