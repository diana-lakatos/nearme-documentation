DesksnearMe::Application.configure do
  config.eager_load = true

  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.serve_static_assets = false
  config.static_cache_control = "public, max-age=7200"

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

  Rails.application.routes.default_url_options[:protocol] = 'https'

  config.assets.compile = false
  config.assets.manifest = "#{Rails.root}/config/manifest.json"

  Rails.application.routes.default_url_options[:host] = 'staging.near-me.com'
  config.test_email = "notifications-staging@desksnear.me"

  # Clould services credentials
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider                   => 'AWS',
      :aws_access_key_id          => 'AKIAI5EVP6HB47OZZXXA',
      :aws_secret_access_key      => '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'
    }
    config.fog_directory        = 'near-me.staging'
    config.asset_host           = 'https://s3.amazonaws.com/near-me.staging'
    config.storage              = :fog
  end

  config.action_controller.asset_host = "//near-me-assets-staging.s3.amazonaws.com"
  config.action_mailer.asset_host = "http://near-me-assets-staging.s3.amazonaws.com"

  # Staging specific keys/secrets for social properties.
  config.linkedin_key = "26pmsiwpsh8a"
  config.linkedin_secret = "M2TZrt7sF7QlIeUZ"

  config.facebook_key = ENV['FB_KEY'] || "491810927536381"
  config.facebook_secret = ENV['FB_SECRET'] || "cce1576ac9f3c4d6998f2c9345360afe"

  config.twitter_key = "8M9qYWg2v2hjTotXg9cWw"
  config.twitter_secret = "qnP1hPJ1kb2AaN7XTTfN3K4VT3SRN48UWe3vMNtVfEg"

  config.instagram_key = "f9aee2b90cc5493bb60f777fee06af52"
  config.instagram_secret = "8b20585b0edd47e7b5ed090616c24d0b"

  config.paypal_email = "admin-facilitator@desksnear.me"
  config.paypal_username = "admin-facilitator_api1.desksnear.me"
  config.paypal_password = "1389316325"
  config.paypal_signature = "AFcWxV21C7fd0v3bYYYRCpSSRl31AfwNFfSck.jyTHBGORF1UEKNUBhL"
  config.paypal_client_id = "AecizhC4a7ZiGUA25DjOzYwDQSy_gVc7hOcf8zc40P27gZwwlqWTU6zU9Crs"
  config.paypal_client_secret = "EKsS3BBF49ckwHJGhGwvj4p8QNfBbhWEqk9PdJI9tqo6SQkLGf9KBiMMOiGh"
  config.paypal_app_id = "APP-80W284485P519543T"

  config.stripe_api_key = "sk_test_lpr4WQXQdncpXjjX6IJx01W7"
  config.stripe_public_key = "pk_test_iCGA8nFZdILrI1UtuMOZD2aq"

  config.balanced_api_key = "ak-prod-1YZGzrMTbG9Q4XeITwLML1za00VRsV4PS"

  # Protect this environment with a simple Basic authentication dialog
  # config.middleware.insert_before(Rack::Sendfile, "Rack::Auth::Basic") do |username, password|
  #   username == 'desksnearme' && password == 'sharethem'
  # end
  config.redis_settings = YAML.load_file(Rails.root.join("config", "redis.yml"))["staging"]
  config.cache_store = :redis_store, {
    :host => config.redis_settings["host"],
    :port => config.redis_settings["port"].to_i,
    :namespace => "cache"
  }
  config.root_secured = false
  config.secure_app = false
end
