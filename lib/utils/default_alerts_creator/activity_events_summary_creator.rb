class Utils::DefaultAlertsCreator::ActivityEventsSummaryCreator < Utils::DefaultAlertsCreator::WorkflowCreator

  def create_all!
    create_activity_events_summary_email!
  end

  def create_activity_events_summary_email!
    create_alert!(
      {
        associated_class: WorkflowStep::ActivityEventsWorkflow::ActivityEventsSummary,
        name: 'activity events summary',
        path: 'activity_events_mailer/activity_events_summary',
        subject: 'summary',
        alert_type: 'email',
        recipient_type: 'enquirer'
      }
    )
  end

  protected

  def workflow_type
    'activity_events_summary'
  end

end
