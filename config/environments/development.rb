DesksnearMe::Application.configure do

  config.cache_classes = false

  config.whiny_nils = true

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.reload_classes_only_on_change = false

  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  Rails.application.routes.default_url_options[:protocol] = 'http'

  config.active_support.deprecation = :log

  config.action_dispatch.best_standards_support = :builtin

  config.assets.digest = false

  config.exceptions_app = nil

  config.filepicker_rails.api_key = "AFWbvclyPQ4WjIIrem35wz"

  # Don't perform mixpanel requests for development
  config.perform_mixpanel_requests = false
end
