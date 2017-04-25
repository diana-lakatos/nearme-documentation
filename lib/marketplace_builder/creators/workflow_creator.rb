# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class WorkflowCreator < DataCreator
      def execute!
        workflows = get_data
        return if workflows.empty?

        workflows.keys.each do |key|
          workflow_attributes = workflows[key]
          workflow_steps = workflow_attributes.delete('workflow_steps')
          workflow = create_or_update_workflow(workflow_attributes)

          workflow_steps.each do |workflow_step_attributes|
            workflow_alerts = workflow_step_attributes.delete('workflow_alerts')
            workflow_step = create_or_update_workflow_step(workflow, workflow_step_attributes)

            workflow_alerts.each do |workflow_alert_attributes|
              create_or_update_workflow_alert(workflow_step, workflow_alert_attributes)
            end
          end
        end
      end

      def cleanup!
        Workflow.delete_all
        WorkflowStep.delete_all
        WorkflowAlert.delete_all
      end

      private

      def create_or_update_workflow(workflow_attributes)
        workflow = Workflow.where(workflow_type: workflow_attributes['workflow_type']).first_or_initialize
        workflow.assign_attributes workflow_attributes
        workflow.save!
        workflow
      end

      def create_or_update_workflow_step(workflow, workflow_step_attributes)
        workflow_step = workflow.workflow_steps.where(
          name: workflow_step_attributes['name'],
          associated_class: workflow_step_attributes['associated_class']
        ).first_or_initialize
        workflow_step.assign_attributes workflow_step_attributes
        workflow_step.save!
        workflow_step
      end

      def create_or_update_workflow_alert(workflow_step, workflow_alert_attributes)
        workflow_alert = workflow_step.workflow_alerts.where(template_path: workflow_alert_attributes['template_path']).first_or_initialize
        workflow_alert.assign_attributes workflow_alert_attributes
        workflow_alert.save!
      end

      def source
        File.join('workflows')
      end
    end
  end
end
