DesksnearMe::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.serve_static_assets = false

  config.action_mailer.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  # Set Stripe config to live config
  config.stripe_api_key = "sk_live_YJet2CBSWgQ2UeuvQiG0vKEC"
  config.stripe_public_key = "pk_live_h3zjCFhi02B4c9juuzmFOe3n"
end
