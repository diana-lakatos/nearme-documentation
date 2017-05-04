module MarketplaceBuilder
  module BuilderTests
    class ShouldImportWorkflows < ActiveSupport::TestCase
      def initialize(instance)
        @workflow = Workflow.last
        @workflow_step = WorkflowStep.last
        @workflow_alert = WorkflowAlert.last
      end

      def execute!
        compare_workflow
        compare_workflow_step
        compare_workflow_alert
      end

      private

      def compare_workflow
        assert_equal @workflow.name, 'test workflow'
        assert_equal @workflow.workflow_steps.count, 1
      end

      def compare_workflow_step
        assert_equal @workflow_step.name, 'test step'
        assert_equal @workflow_step.associated_class, 'WorkflowStep::CommenterWorkflow::UserCommentedOnUserUpdate'
        assert_equal @workflow_step.workflow_alerts.count, 1
      end

      def compare_workflow_alert
        assert_equal @workflow_alert.name, 'test alert'
        assert_equal @workflow_alert.alert_type, 'email'
        assert_equal @workflow_alert.recipient_type, 'lister'
        assert_equal @workflow_alert.template_path, 'user_mailer/user_commented_on_user_update'
      end
    end
  end
end
