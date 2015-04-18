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

        saved_searches_ids_results_hash = user.saved_searches.inject({}) do |hsh, saved_search|
          new_results = saved_search.fetch_new_results
          hsh[saved_search.id] = new_results.size if new_results.size > 0
          hsh
        end

        unless saved_searches_ids_results_hash.empty?
          klass = @period == :daily ? WorkflowStep::SavedSearchWorkflow::Daily : WorkflowStep::SavedSearchWorkflow::Weekly
          WorkflowStepJob.perform(klass, saved_searches_ids_results_hash)
        end
      end
    end
    PlatformContext.current = nil
  end

end
