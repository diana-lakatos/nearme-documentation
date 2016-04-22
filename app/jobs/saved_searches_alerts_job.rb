class SavedSearchesAlertsJob < Job
  def after_initialize(period)
    @period = period
  end

  def perform
    Instance.find_each do |instance|
      PlatformContext.current = PlatformContext.new(instance)
      conditions_sql = <<-SQL
          saved_searches_alerts_frequency = ?
            AND
          saved_searches_count > 0
            AND
          (saved_searches_alert_sent_at IS NULL OR saved_searches_alert_sent_at < ?)
        SQL

      User.where(conditions_sql, @period.to_s, @period == :daily ? 1.day.ago : 1.week.ago).find_each do |user|
        # move timestamp to beginning of hour, unless period will be smaller than needed one
        user.update_column :saved_searches_alert_sent_at, Time.zone.now.beginning_of_hour

        saved_searches_ids = user.saved_searches.inject([]) do |ar, saved_search|
          new_results = saved_search.fetch_new_results
          saved_search.update_column :new_results, new_results.size
          if new_results.present?
            ar << saved_search.id
            saved_search.alert_logs.create(results_count: new_results.size)
          end
          ar
        end

        unless saved_searches_ids.empty?
          klass = @period == :daily ? WorkflowStep::SavedSearchWorkflow::Daily : WorkflowStep::SavedSearchWorkflow::Weekly
          WorkflowStepJob.perform(klass, saved_searches_ids)
        end
      end
    end
    PlatformContext.current = nil
  end
end
