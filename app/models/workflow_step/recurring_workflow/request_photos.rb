class WorkflowStep::RecurringWorkflow::RequestPhotos < WorkflowStep::RecurringWorkflow::BaseStep
  def initialize(listing_id)
    @transactable = Transactable.find_by_id(listing_id)
  end

  def lister
    @transactable.administrator
  end

  def enquirer
    @transactable.administrator
  end

  def data
    { listing: @transactable, user: @transactable.administrator }
  end
end
