DesksnearMe::Application.configure do
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

  Rails.application.routes.default_url_options[:host] = 'desksnear.me'
  Rails.application.routes.default_url_options[:protocol] = 'https'

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  config.assets.compile = false
  config.assets.compress = true
  config.assets.js_compressor = :uglifier

  # Clould services credentials
  config.fog_directory        = 'desksnearme.production'
  config.asset_host           = 'https://s3.amazonaws.com/desksnearme.production'
  config.storage              = :fog

  config.action_controller.asset_host = "//desksnear.me"

  # Production specific app keys/secrets for social properties.
  config.linkedin_key = "2qyp4vpjl8uh"
  config.linkedin_secret = "PQfyGFyutsoPwcOY"

  config.facebook_key = "301871243226028"
  config.facebook_secret = "ac8bb27ccebedccc7535d0df73e60640"

  config.twitter_key = "687jaGPQNpLHlK0An6zy7g"
  config.twitter_secret = "b6WZm6oyfh1bou4Nn7ntybL2g5pK9zEaabUqMVeRU"

  config.instagram_key = "5aa60d9c54ba49f086cec9693ba442c5"
  config.instagram_secret = "70d8ada7eea04223ad04d40ddd30c642"
  config.paypal_mode = 'live'
  config.redis_settings = YAML.load_file(Rails.root.join("config", "redis.yml"))["production"]
  config.cache_store = :redis_store, {
    :host => config.redis_settings["host"],
    :port => config.redis_settings["port"].to_i,
    :namespace => "cache"
  }
end
