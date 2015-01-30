WorkflowAlertLogger.setup do |config|
  if Rails.env.test?
    config.logger_type = :none
  else
    config.logger_type = :db
  end
end
