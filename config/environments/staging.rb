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
    :enable_starttls_auto => true,
    :user_name      => "admin@desksnear.me",
    :password       => "K6c#H3UWi}%DD6vUT$9W",
    :domain         => 'desksnear.me'
  }

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  # Uncomment if you precompile assets
  # config.assets.compile = false

  config.assets.compress = true
  config.assets.js_compressor = :uglifier

  # Staging specific keys/secrets for social properties.
  config.linkedin_key = "26pmsiwpsh8a"
  config.linkedin_secret = "M2TZrt7sF7QlIeUZ"

  config.facebook_key = "491810927536381"
  config.facebook_secret = "cce1576ac9f3c4d6998f2c9345360afe"

  config.twitter_key = "8M9qYWg2v2hjTotXg9cWw"
  config.twitter_secret = "qnP1hPJ1kb2AaN7XTTfN3K4VT3SRN48UWe3vMNtVfEg"
end
