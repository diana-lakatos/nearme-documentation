class WorkflowStep::SpamReportWorkflow::SummaryStep < WorkflowStep::BaseStep
  def initialize(spam_report_count)
    @spam_report_count = spam_report_count
  end

  def workflow_type
    'spam_report'
  end

  def workflow_triggered_by
    nil # Called from job
  end

  # amount_or_no:
  #   no - if the spam report count is 0, otherwise the number of spam reports
  # date:
  #   current date
  def data
    {
      amount_or_no: (@spam_report_count == 0 ? 'no' : @spam_report_count),
      date: I18n.l(Date.current, format: :short)
    }
  end
end
