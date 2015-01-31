class WorkflowStep::InquiryWorkflow::BaseStep < WorkflowStep::BaseStep

  def initialize(inquiry_id)
    @inquiry = Inquiry.find_by_id(inquiry_id)
  end

  def workflow_type
    'inquiry'
  end

  def enquirer
    @inquiry.inquiring_user
  end

  def lister
    @inquiry.listing.creator
  end

  def data
    { inquiry: @inquiry }
  end

end
