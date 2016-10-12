DesksnearMe::Application.configure do
  config.use_only_ssl = false
  config.cache_classes = true

  config.eager_load = false

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  Rails.application.routes.default_url_options[:protocol] = 'http'
  config.active_support.deprecation = :log
  config.action_dispatch.best_standards_support = :builtin
  config.assets.digest = false
  config.exceptions_app = nil
  # Don't perform mixpanel and google analytics requests for development
  config.perform_mixpanel_requests = false
  config.perform_google_analytics_requests = false
  config.perform_social_jobs = false

  config.encrypt_sensitive_db_columns = true
  config.silence_raygun_notification = true
  config.assets.enforce_precompile = true

  config.root_secured = false
  config.secure_app = false
  config.run_jobs_in_background = false
end
