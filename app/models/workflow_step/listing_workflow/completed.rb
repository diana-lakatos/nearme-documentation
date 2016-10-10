class WorkflowStep::ListingWorkflow::Completed < WorkflowStep::ListingWorkflow::BaseStep
  def enquirer
    @transactable.line_item_orders.confirmed.first.user
  end
end
