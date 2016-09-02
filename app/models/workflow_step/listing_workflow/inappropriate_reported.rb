class WorkflowStep::ListingWorkflow::InappropriateReported < WorkflowStep::ListingWorkflow::BaseStep

  def initialize(inappropriate_report_id)
    @inappropriate_report = InappropriateReport.find(inappropriate_report_id)
    @transactable = @inappropriate_report.reportable
  end

  def data
    { listing: @transactable, reporter: @inappropriate_report.user, reason: @inappropriate_report.reason }
  end

  def transactable_type_id
    @transactable.try(:transactable_type_id)
  end

end

