class WorkflowStep::ListingWorkflow::Completed < WorkflowStep::ListingWorkflow::BaseStep
  def enquirer
    @transactable.line_item_orders.confirmed_or_archived.first.user
  end
end
