class WorkflowStep::SupportWorkflow::Created < WorkflowStep::SupportWorkflow::BaseStep
  def workflow_triggered_by
    @message.ticket.user
  end
end
