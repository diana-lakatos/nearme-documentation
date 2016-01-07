DesksnearMe::Application.configure do
  config.eager_load = true

  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.serve_static_files = false
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

  config.middleware.swap Rails::Rack::Logger, NullLogger, silence: %w('/ping')

  # Clould services credentials
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider                   => 'AWS',
      :aws_access_key_id          => 'AKIAJC37Z6XCOCR245YA',
      :aws_secret_access_key      => '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',
      :region                     => 'us-west-1',
      :path_style                 => true
    }
    config.fog_directory        = 'near-me.staging'
    config.asset_host           = 'https://staging-uploads-nearme.netdna-ssl.com'
    config.storage              = :fog
  end

  config.action_controller.asset_host = "https://staging-nearme.netdna-ssl.com"
  config.action_mailer.asset_host     = "https://staging-nearme.netdna-ssl.com"

  config.paypal_email = "admin-facilitator@desksnear.me"
  config.paypal_username = "admin-facilitator_api1.desksnear.me"
  config.paypal_password = "1389316325"
  config.paypal_signature = "AFcWxV21C7fd0v3bYYYRCpSSRl31AfwNFfSck.jyTHBGORF1UEKNUBhL"
  config.paypal_client_id = "AecizhC4a7ZiGUA25DjOzYwDQSy_gVc7hOcf8zc40P27gZwwlqWTU6zU9Crs"
  config.paypal_client_secret = "EKsS3BBF49ckwHJGhGwvj4p8QNfBbhWEqk9PdJI9tqo6SQkLGf9KBiMMOiGh"
  config.paypal_app_id = "APP-80W284485P519543T"

  # Protect this environment with a simple Basic authentication dialog
  # config.middleware.insert_before(Rack::Sendfile, "Rack::Auth::Basic") do |username, password|
  #   username == 'desksnearme' && password == 'sharethem'
  # end
  config.redis_settings = YAML.load_file(Rails.root.join("config", "redis.yml"))["staging"]
  config.redis_cache_client = Redis
  config.cache_store = :redis_store, {
    :host => config.redis_settings["host"],
    :port => config.redis_settings["port"].to_i,
    :namespace => "cache"
  }
  config.root_secured = false
  config.secure_app = true
  config.send_real_sms = true
end
