require File.expand_path('../boot', __FILE__)

require 'rails/all'

groups = {}
groups[:coverage]  =  [Rails.env.to_s] if ENV['COVERAGE']
groups[:profiling] =  [Rails.env.to_s] if ENV['PERF']

Bundler.require(*Rails.groups(groups)) if defined?(Bundler)

require File.dirname(__FILE__) + '/../lib/null_logger.rb'
require File.dirname(__FILE__) + '/../lib/null_redis_cache.rb'
require File.dirname(__FILE__) + '/../lib/marketplace_error_logger.rb'

module DesksnearMe
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_record.raise_in_transactional_callbacks = true
    ActiveRecord::Base.store_base_sti_class = false

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths -= Dir["#{config.root}/lib/previewers/"] unless defined? MailView

    config.to_prepare do
      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load Spree model's decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/models/spree/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load liquid tags
      Dir.glob(File.join(File.dirname(__FILE__), "../app/liquid_tags/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load Spree controllers's decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/controllers/spree/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    config.assets.paths           << %(#{Rails.root}/app/assets/fonts)
    config.assets.paths           << %(#{Rails.root}/app/assets/swfs)
    config.assets.paths           << %(#{Rails.root}/app/assets/videos)

    config.assets.precompile += [
      'ckeditor/*',
      'jquery.js',
      'select2.js'
    ]
    config.assets.precompile += [
      "vendor/jquery.backgroundSize.min.js","vendor/respond.proxy.js", "vendor/respond.min.js",
      "admin.js", "blog.js", "blog_admin.js", "chrome_frame.js", "instance_admin.js", "community.js",
      "platform_home.js", "analytics/sessioncam.js", "blog/admin/*", 'dashboard.js', "new_ui.js", "new_ui/vendor/modernizr.js"
    ]
    config.assets.precompile += [
      "browser_specific/ie8.css", "admin.css", "blog.css", "blog_admin.css", "errors.css",
      "instance_admin.css", "platform_home.css", "instance_admin/shipping_profiles_includes.css",
      "dashboard.css", 'vendor/powerange.css', 'instance_wizard.css', "community.css", "select2.css"
    ]

    config.assets.precompile += [
      'glyphicons-halflings.png',
      'glyphicons-halflings-white.png'
    ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.i18n.enforce_available_locales = false
    I18n.config.enforce_available_locales = false

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [
      :password, :bank_account_number, :response,
      :marketplace_password, :olark_api_key, :facebook_consumer_key, :facebook_consumer_secret, :twitter_consumer_key,
      :twitter_consumer_secret, :linkedin_consumer_key, :linkedin_consumer_secret, :instagram_consumer_key, :instagram_consumer_secret,
      :live_settings, :test_settings, :card_number, :card_exp_month, :card_exp_year, :card_code
    ]

    config.generators do |g|
      g.test_framework :test_unit, :fixture => false
    end
    config.use_only_ssl = true

    # note that we *don't* want to rewite for the test env :)
    config.should_rewrite_email = Rails.env.staging? || Rails.env.development?
    config.test_email           = ENV['DNM_TEST_EMAIL'] || "notifications@desksnear.me"

    config.action_mailer.default_url_options = { :host => 'desksnear.me' }

    # Access the DB or load models when precompiling assets
    config.assets.initialize_on_precompile = true

    config.assets.prefix = ENV['ASSETS_PREFIX'].presence || config.assets.prefix

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.digest = true

    # Clould services credentials
    CarrierWave.configure do |config|
      config.fog_attributes = {'Cache-Control'=>'max-age=315576000, public'}
      config.storage        = :file
    end

    # Development/Test specific keys/secrets for social properties.
    config.linkedin_key = "4q9xfgn60bik"
    config.linkedin_secret = "lRmKVrc0RPpfKDCV"

    config.facebook_key = "432038396866156"
    config.facebook_secret = "71af86082de1c38a3523a4c8f44aca2d"

    config.twitter_key = "Xas2mKTWPVpqrb5FXUnDg"
    config.twitter_secret = "nR8pjJ9YcU3eK9pKUPFBNxZuJ5oMci2M96SpZ47Ik"

    config.instagram_key = "566499e0d6e647518d8f4cec0a42f3d6"
    config.instagram_secret = "5c0652ad06984bf09e4987c8fc5ea8f1"

    config.exceptions_app = self.routes

    # setting platform_context in app/models/platform_context/rack_setter.rb
    config.middleware.use "PlatformContext::RackSetter"
    config.middleware.use Rack::Deflater

    config.mixpanel = (YAML.load_file(Rails.root.join("config", "mixpanel.yml"))[Rails.env] || {}).with_indifferent_access
    config.google_analytics = (YAML.load_file(Rails.root.join("config", "google_analytics.yml"))[Rails.env] || {}).with_indifferent_access
    config.near_me_analytics = (YAML.load_file(Rails.root.join("config", "near_me_analytics.yml"))[Rails.env] || {}).with_indifferent_access

    config.perform_mixpanel_requests = true
    config.perform_google_analytics_requests = true
    config.perform_social_jobs = true
    # we do not use it, but won't harm
    config.active_job.queue_adapter = :delayed_job

    config.action_dispatch.rescue_responses.merge!('Page::NotFound' => :not_found)
    config.action_dispatch.rescue_responses.merge!('Location::NotFound' => :not_found)
    config.action_dispatch.rescue_responses.merge!('UserBlog::NotFound' => :not_found)
    config.action_dispatch.rescue_responses.merge!('Transactable::NotFound' => :not_found)

    config.paypal_mode = 'sandbox'
    config.encrypt_sensitive_db_columns = true

    config.silence_raygun_notification = false

    config.paypal_email = nil
    config.paypal_username = nil
    config.paypal_password = nil
    config.paypal_signature = nil
    config.paypal_client_id = nil
    config.paypal_client_secret = nil
    config.paypal_app_id = nil

    config.stripe_api_key = nil
    config.stripe_public_key = nil

    config.secure_app = true
    config.root_secured = true
    config.run_jobs_in_background = true
    config.send_real_sms = false
    config.googl_api_key = nil

    config.default_cache_expires_in = 30.minutes
    config.marketplace_error_logger = MarketplaceErrorLogger::ActiveRecordLogger.new
    config.force_disable_es = false
    config.active_merchant_billing_gateway_app_id = 'NearMe_SP'
    config.redis_cache_client = NullRedisCache

    config.attachment_upload_file_types = %w(doc docx xls odt ods pdf rar zip tar tar.gz swf mp4 css txt text js xlsx)
    config.private_upload_file_types = %w(jpg jpeg png pdf doc docx)
  end
end
