DesksnearMe::Application.configure do
  config.eager_load = true

  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = 'X-Sendfile'
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=7200'

  config.action_mailer.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: '587',
    authentication: :plain,
    enable_starttls_auto: true,
    user_name: 'admin@desksnear.me',
    password: ENV['MAILER_SMTP_PASSWORD'],
    domain: 'desksnear.me'
  }

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  Rails.application.routes.default_url_options[:protocol] = 'https'

  config.assets.compile = false
  config.assets.prefix = '/assets'

  Rails.application.routes.default_url_options[:host] = 'staging.near-me.com'
  config.test_email = 'notifications-staging@desksnear.me'

  config.middleware.swap Rails::Rack::Logger, NullLogger, silence: %w(/ping)

  # Clould services credentials
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['FOG_AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['FOG_AWS_ACCESS_KEY_SECRET'],
      region: ENV['ELB_REGION'],
      path_style: true
    }
    config.fog_directory        = ENV['FOG_DIRECTORY']
    config.asset_host           = ENV['ASSET_HOST_UPLOAD']
    config.storage              = :fog
  end

  config.action_controller.asset_host = ENV['ASSET_HOST']
  config.action_mailer.asset_host     = ENV['ASSET_HOST']

  # Protect this environment with a simple Basic authentication dialog
  # config.middleware.insert_before(Rack::Sendfile, "Rack::Auth::Basic") do |username, password|
  #   username == 'desksnearme' && password == 'sharethem'
  # end
  config.redis_settings = YAML.load_file(Rails.root.join('config', 'redis.yml'))['staging']
  config.redis_cache_client = Redis
  config.cache_store = :redis_store, {
    host: config.redis_settings['host'],
    port: config.redis_settings['port'].to_i,
    namespace: 'cache'
  }
  config.root_secured = false
  config.secure_app = true
  config.send_real_sms = true

  config.webpack[:use_manifest] = true
  config.assets.manifest = "#{Rails.root}/public/assets/manifest.json"
end
