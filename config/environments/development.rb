DesksnearMe::Application.configure do
  config.use_only_ssl = false
  config.cache_classes = false

  config.eager_load = false

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.reload_classes_only_on_change = true

  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  Rails.application.routes.default_url_options[:protocol] = 'http'

  config.active_support.deprecation = :log

  config.action_dispatch.best_standards_support = :builtin

  config.assets.digest = false

  config.exceptions_app = nil

  config.filepicker_rails.api_key = "AFWbvclyPQ4WjIIrem35wz"

  # Don't perform mixpanel and google analytics requests for development
  config.perform_mixpanel_requests = false
  config.perform_google_analytics_requests = false
  config.perform_social_jobs = false

  config.twitter_key = "IZeQXx4YyCdTQ9St3tmyw"
  config.twitter_secret = "ZlxMPIhNPBn4QbOSHqkN1p7hKghGZTOtR1fDsPSX8"
  config.encrypt_sensitive_db_columns = false
  config.silence_raygun_notification = true
  config.assets.enforce_precompile = true

  config.root_secured = false
  config.secure_app = false
  config.run_jobs_in_background = false
end
