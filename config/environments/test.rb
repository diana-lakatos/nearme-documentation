DesksnearMe::Application.configure do
  config.use_only_ssl = false
  Rails.application.routes.default_url_options[:host] = 'example.com'
  config.action_controller.allow_forgery_protection    = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :log
  config.cache_classes = true
  config.consider_all_requests_local       = true
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'
  config.assets.compile = true
  config.assets.raise_runtime_errors = false

  config.perform_social_jobs = false
  config.after_initialize do
    PaperTrail.enabled = false
  end
  config.encrypt_sensitive_db_columns = false
  config.silence_raygun_notification = true
  config.cache_store = :memory_store

  config.secure_app = false
  config.root_secured = false

  config.eager_load = true
  config.run_jobs_in_background = false
  config.allow_concurrency = false

  config.webpack[:use_manifest] = true
  config.assets.manifest = "#{Rails.root}/public/assets/manifest.json"

  config.middleware.use Rack::NoAnimations
  config.verify_api_requests = false
  config.force_sending_all_workflow_alerts = true
  config.use_elastic_search = false
end
