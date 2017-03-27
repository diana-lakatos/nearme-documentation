# frozen_string_literal: true
class WorkflowStep::SupportWorkflow::Updated < WorkflowStep::SupportWorkflow::BaseStep
  def workflow_triggered_by
    @message.user
  end
end
