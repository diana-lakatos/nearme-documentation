# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class ShouldImportWorkflows < ActiveSupport::TestCase
      def initialize(_instance)
        @workflow = Workflow.last
        @workflow_step = @workflow.workflow_steps.last
        @workflow_alert = @workflow_step.workflow_alerts.last
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
        assert_equal 'test alert', @workflow_alert.name
        assert_equal 'email', @workflow_alert.alert_type
        assert_equal 'lister', @workflow_alert.recipient_type
        assert_equal 'user_mailer/user_commented_on_user_update', @workflow_alert.template_path
      end
    end
  end
end
