DesksnearMe::Application.configure do
  Rails.application.routes.default_url_options[:host] = "example.com"
  config.action_controller.allow_forgery_protection    = false
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = true
  config.action_mailer.delivery_method = :test
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_support.deprecation = :stderr
  config.cache_classes = true
  config.consider_all_requests_local       = true
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"
  config.whiny_nils = true

  # Set Stripe config to no config setup for Tests
  config.stripe_api_key = nil
  config.stripe_public_key = nil

  # Find friends after create
  config.find_friends_after_create = false
end
