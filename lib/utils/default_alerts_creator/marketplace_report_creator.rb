class Utils::DefaultAlertsCreator::MarketplaceReportCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    create_report_generated!
  end

  def create_report_generated!
    create_alert!(associated_class: WorkflowStep::MarketplaceReportWorkflow::Generated, name: 'report_generation_done', path: 'marketplace_reports_mailer/report_generation_done', subject: "[{{platform_context.name}}] Your requested report has been generated", alert_type: 'email', recipient_type: 'enquirer')
  end

  protected

  def workflow_type
    'marketplace_report'
  end
end
