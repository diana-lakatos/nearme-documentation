require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportWorkflows < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        workflow = Workflow.create! name: 'test workflow',
          instance_id: @instance.id,
          workflow_type: 'test'

        workflow_step = WorkflowStep.create! workflow: workflow,
          name: 'test workflow',
          instance_id: @instance.id,
          associated_class: WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate

        WorkflowAlert.create! workflow_step: workflow_step,
          name: 'test',
          alert_type: 'email',
          recipient_type: 'lister',
          template_path: 'user_mailer/user_commented_on_user_update'
      end

      def execute!
        yaml_content = read_exported_file('workflows/test.yml')

        assert_equal yaml_content, 'name' => 'test workflow', 'workflow_type' => 'test', 'events_metadata' => {}, 'workflow_steps' => [
          { 'name' => 'test workflow',
            'associated_class' => 'WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate',
            'workflow_alerts' => [
              { 'name' => 'test',
                'alert_type' => 'email',
                'recipient_type' => 'lister',
                'template_path' => 'user_mailer/user_commented_on_user_update',
                'delay' => 0 }
            ] }
        ]
      end
    end
  end
end
