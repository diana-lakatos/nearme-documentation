class Utils::DefaultAlertsCreator::SavedSearchCreator < Utils::DefaultAlertsCreator::WorkflowCreator
  def create_all!
    notify_user_of_daily_results!
    notify_user_of_weekly_results!
  end

  def notify_user_of_daily_results!
    create_alert!(
      associated_class: WorkflowStep::SavedSearchWorkflow::Daily,
      name: 'notify_user_of_daily_results',
      path: 'saved_search_mailer/notify_user_of_daily_results',
      subject: "[{{platform_context.name}}] #{I18n.t('saved_searches.mailer.subject.daily.new_search_results')} {{saved_searches_titles}}",
      alert_type: 'email',
      recipient_type: 'enquirer'
    )
  end

  def notify_user_of_weekly_results!
    create_alert!(
      associated_class: WorkflowStep::SavedSearchWorkflow::Weekly,
      name: 'notify_user_of_weekly_results',
      path: 'saved_search_mailer/notify_user_of_weekly_results',
      subject: "[{{platform_context.name}}] #{I18n.t('saved_searches.mailer.subject.weekly.new_search_results')} {{saved_searches_titles}}",
      alert_type: 'email',
      recipient_type: 'enquirer'
    )
  end

  protected

  def workflow_type
    'saved_search'
  end
end
