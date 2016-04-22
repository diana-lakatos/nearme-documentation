class WorkflowStep::ListingWorkflow::InappropriateReported < WorkflowStep::ListingWorkflow::BaseStep

  def initialize(transactable_id, inappropriate_report_id = nil)
    @transactable = Transactable.find_by_id(transactable_id)
    @inappropriate_report = @transactable.inappropriate_reports.find(inappropriate_report_id)
  end

  def data
    { listing: @transactable, reporter: @inappropriate_report.user, reason: @inappropriate_report.reason }
  end

end

