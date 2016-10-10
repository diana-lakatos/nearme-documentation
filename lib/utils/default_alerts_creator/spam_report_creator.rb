class Utils::DefaultAlertsCreator::SpamReportCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_summary_email!
  end

  def create_summary_email!
    create_alert!(
      associated_class: WorkflowStep::SpamReportWorkflow::SummaryStep,
      name: 'spam_report',
      path: 'spam_reports_mailer/summary',
      subject: '[{{date}}] - {{amount_or_no}} Spam Reports on {{platform_context.name}}',
      alert_type: 'email',
      recipient_type: 'Administrator'
    )
  end

  protected

  def workflow_type
    'spam_report'
  end
end
