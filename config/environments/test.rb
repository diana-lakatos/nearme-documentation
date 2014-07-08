DesksnearMe::Application.configure do
  config.use_only_ssl = false
  Rails.application.routes.default_url_options[:host] = "example.com"
  config.action_controller.allow_forgery_protection    = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :log
  config.cache_classes = true
  config.consider_all_requests_local       = true
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  config.perform_social_jobs = false
  config.after_initialize do
      PaperTrail.enabled = false
  end
  config.encrypt_sensitive_db_columns = false
  config.silence_raygun_notification = true
  config.cache_store = :memory_store

  config.secure_app = false
  config.root_secured = false

  config.eager_load = false
end
