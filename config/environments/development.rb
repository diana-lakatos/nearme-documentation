# frozen_string_literal: true
require 'rack-mini-profiler'
require 'new_relic/rack/developer_mode'

DesksnearMe::Application.configure do
  # true to turn on caching
  config.action_controller.perform_caching = false
  # comment to turn on caching
  config.cache_store = :null_store

  config.cache_classes = false
  config.eager_load = false
  config.use_only_ssl = false

  config.consider_all_requests_local = true
  config.reload_classes_only_on_change = true

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  Rails.application.routes.default_url_options[:protocol] = 'http'

  config.active_support.deprecation = :log

  config.action_dispatch.best_standards_support = :builtin

  config.assets.digest = false
  config.assets.debug = false
  config.assets.raise_runtime_errors = false
  config.assets.enforce_precompile = true

  config.assets.paths << %(#{Rails.root}/public/assets)

  config.exceptions_app = nil

  config.perform_social_jobs = false

  config.encrypt_sensitive_db_columns = false
  config.silence_raygun_notification = true

  config.root_secured = false
  config.secure_app = false
  config.run_jobs_in_background = ENV['RUN_BACKGROUND_JOBS'] == 'true'
  config.debug_graphql = ENV['DEBUG_GRAPHQL'] == 'true'
  config.googl_api_key = 'AIzaSyBV7BhIuT6s2HbprOP4jfXSmpdBFmocSMg'
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }

  config.middleware.swap Rails::Rack::Logger, NullLogger, silence: %w(mini-profiler better_errors)
  config.middleware.insert_after(ActionDispatch::Static, SilentMissedImages)
  config.use_elastic_search = true

  Liquid.cache_classes = false

  config.middleware.use NewRelic::Rack::DeveloperMode if ENV['ENABLE_PROFILER']
  config.active_record.logger = nil if ENV['NO_SQL_LOGS']

  if defined?(Bullet)
    config.after_initialize do
      Bullet.enable = true
      Bullet.rails_logger = true
    end
  end
end

if ENV['ENABLE_PROFILER']
  Rack::MiniProfilerRails.initialize!(Rails.application)
  Rails.application.middleware.delete(Rack::MiniProfiler)
  Rails.application.middleware.insert_after(Rack::Deflater, Rack::MiniProfiler)
  ActiveRecordQueryTrace.enabled = true
end
