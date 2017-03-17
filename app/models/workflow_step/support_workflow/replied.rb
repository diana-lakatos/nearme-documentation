class WorkflowStep::SupportWorkflow::Replied < WorkflowStep::SupportWorkflow::BaseStep
  def workflow_triggered_by
    @message.user
  end
end
