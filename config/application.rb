require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups(:assets => %w(development test))) if defined?(Bundler)

module DesksnearMe
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/inputs #{config.root}/forms)
    config.autoload_paths += Dir["#{config.root}/lib", "#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    config.assets.paths           << %(#{Rails.root}/app/assets/fonts)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.generators do |g|
      g.test_framework :test_unit, :fixture => false
    end

    # note that we *don't* want to rewite for the test env :)
    config.should_rewrite_email = Rails.env.staging? || Rails.env.development?
    config.test_email           = ENV['DNM_TEST_EMAIL'] || "notifications@desksnear.me"

    config.action_mailer.default_url_options = { :host => 'desksnear.me' }

    # Access the DB or load models when precompiling assets
    config.assets.initialize_on_precompile = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.digest = true

    # Stripe payment gateway setup as Test environment.
    # Override in relevant environment config
    config.stripe_api_key = "sk_test_lpr4WQXQdncpXjjX6IJx01W7"
    config.stripe_public_key = "pk_test_iCGA8nFZdILrI1UtuMOZD2aq"

    # Development/Test specific keys/secrets for social properties.
    config.linkedin_key = "4q9xfgn60bik"
    config.linkedin_secret = "lRmKVrc0RPpfKDCV"

    config.facebook_key = "432038396866156"
    config.facebook_secret = "71af86082de1c38a3523a4c8f44aca2d"

    config.twitter_key = "Xas2mKTWPVpqrb5FXUnDg"
    config.twitter_secret = "nR8pjJ9YcU3eK9pKUPFBNxZuJ5oMci2M96SpZ47Ik"

    config.exceptions_app = self.routes

    # custom rewrites specified in lib/rack/legacy_redirect_handler.rb
    config.middleware.insert_before(Rack::Lock, "Rack::LegacyRedirectHandler")
  end
end
