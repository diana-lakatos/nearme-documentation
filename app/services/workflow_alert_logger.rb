class WorkflowAlertLogger
  class Configuration
    attr_accessor :logger_type
  end

  class << self
    def setup
      yield(configuration)
    end

    def configuration
      @configuration ||= ::WorkflowAlertLogger::Configuration.new
    end
  end

  def initialize(workflow_alert)
    @workflow_alert = workflow_alert
  end

  def db_log!
    WorkflowAlertLog.create(
      workflow_alert: @workflow_alert,
      alert_type: @workflow_alert.alert_type,
      workflow_alert_weekly_aggregated_log: WorkflowAlertWeeklyAggregatedLog.find_or_create_for_current_week,
      workflow_alert_monthly_aggregated_log: WorkflowAlertMonthlyAggregatedLog.find_or_create_for_current_month
    )
  end

  def logger_log!
    Rails.logger.debug "Triggered #{@workflow_alert.alert_type}"
  end

  def log!
    case self.class.configuration.logger_type
    when :db
      db_log!
    when :logger
      logger_log!
    when :none, nil
    else
      fail "Unknow WorkflowAlertLogger logger type - #{self.class.configuration.logger_type.inspect}"
    end
  end
end
