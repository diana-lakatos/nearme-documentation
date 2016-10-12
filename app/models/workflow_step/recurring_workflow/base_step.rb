class WorkflowStep::RecurringWorkflow::BaseStep < WorkflowStep::BaseStep
  def workflow_type
    'recurring'
  end
end
