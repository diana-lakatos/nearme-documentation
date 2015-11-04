class SendDailySpamReportsJob < Job
  def perform
    Instance.where(is_community: true).find_each do |instance|
      instance.set_context!
      @spam_reports = SpamReport.where(created_at: 1.day.ago..Time.zone.now)
      WorkflowStepJob.perform(WorkflowStep::SpamReportWorkflow::SummaryStep, @spam_reports.count)
    end
  end
end
