class WorkflowStep::SignUpWorkflow::Approved < WorkflowStep::SignUpWorkflow::BaseStep
  def should_be_processed?
    @user.try(:is_trusted?)
  end
end
