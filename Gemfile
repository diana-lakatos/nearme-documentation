ruby '2.3.1'

source 'http://rubygems.org'

gem 'rails', '4.2.7.1'
gem 'pg'
gem 'will_paginate'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'patron'

gem 'redis'
gem 'redis-rails', '~> 4'
gem 'raygun4ruby'
gem 'liquid', '4.0.0'
gem 'active_model_serializers', '~> 0.8.1'
gem 'jsonapi-serializers', github: 'mdyd-dev/jsonapi-serializers', branch: 'feature/namespace'
gem 'rabl'
gem 'graphql'
gem 'carrierwave'
gem 'carrierwave-imageoptim'
gem 'image_optim_pack'
gem 'devise', '4.2.0'
gem 'devise-token_authenticatable'
gem 'rack-throttle'
gem 'responders'

gem 'rack-reverse-proxy', require: 'rack/reverse_proxy', git: 'git@github.com:mdyd-dev/rack-reverse-proxy.git'

gem 'charlock_holmes', '~> 0.7.3', require: false
gem 'stringex', require: 'stringex_lite' # used by category model

gem 'aws-sdk', require: false

gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '~> 4.0'
gem 'omniauth-linkedin'
gem 'omniauth-instagram'
gem 'omniauth-saml'
gem 'omniauth-google-oauth2'
gem 'omniauth-github'

gem 'koala', require: false
gem 'linkedin-oauth2', '~> 1.0'
gem 'omniauth-linkedin-oauth2'
gem 'twitter', '~> 5.5.1', require: false
# Installing instagram from the master branch will fix ruby 2.2 circular dependency warning
gem 'instagram', require: false
gem 'github_api', require: false
gem 'google_plus', require: false

gem 'reform'
gem 'reform-rails'

gem 'fog'
gem 'geocoder'
gem 'nearest_time_zone', require: false
gem 'haml'
gem 'mini_magick', '~> 4.0.1'
gem 'money-rails', github: 'RubyMoney/money-rails'
gem 'simple_form', '~> 3.1'
gem 'paranoia', github: 'radar/paranoia', branch: 'rails4'
gem 'nested_form'

gem 'nokogiri', '~> 1.6.0'
gem 'ri_cal', require: false
gem 'draper'
gem 'counter_culture'
gem 'ice_cube', '0.13.0', require: false # upgrading to 0.14.0 breaks things
gem 'rails_autolink'

gem 'i18n-active_record',
    git: 'git://github.com/svenfuchs/i18n-active_record.git',
    require: 'i18n/active_record'

gem 'paper_trail', '5.2.0'

gem 'rack-rewrite', require: 'rack/rewrite'

gem 'state_machine', '~> 1.2.0'
gem 'state_machines-activerecord'
gem 'awesome_nested_set', require: false
gem 'font-awesome-rails'

gem 'delayed_job_active_record'
gem 'delayed_job_recurring'
gem 'rdiscount', require: false
gem 'attr_encrypted', '~> 1'
gem 'stripe', '1.57.0', require: false
gem 'plaid', require: false
gem 'paypal-sdk-rest', '~> 1.3.2'
gem 'paypal-sdk-merchant'
gem 'paypal-sdk-adaptivepayments'
gem 'braintree', '2.46.0', require: false
gem 'friendly_id', '~> 5.1'

gem 'chronic'

gem 'unicorn'

gem 'ckeditor', github: 'galetahub/ckeditor'
gem 'orm_adapter', '~> 0.5.0' # needed for ckeditor, see https://github.com/galetahub/ckeditor/issues/375
gem 'sanitize', require: false

gem 'useragent', require: false

gem 'daemons' # used by DelayedJob

gem 'twilio-ruby', require: false
gem 'googl', require: false

gem 'inherited_resources', '~> 1.6'

gem 'ranked-model'

gem 'after_commit_action'

gem 'premailer-rails'
gem 'hpricot' # used by premailer, premailer is used to insert token?
gem 'addressable', require: false
gem 'newrelic_rpm'
gem 'unicorn-worker-killer'

gem 'activemerchant'

gem 'shippo'

gem 'video_info', require: false

# store base is also used for payment gateways
gem 'store_base_sti_class', github: 'jcarreti/store_base_sti_class', branch: 'rails4-2'
gem 'domainatrix', require: false

gem 'acts-as-taggable-on', '~> 3.4'

gem 'validate_url'
gem 'ansi', require: false

gem 'yard', '~> 0.9.5', require: false
gem 'yard-activerecord', '~> 0.0.16', require: false

gem 'jira-ruby', require: false

group :profiling, :development do
  gem 'rack-mini-profiler', require: false
  gem 'flamegraph', require: false
  gem 'bullet', require: false
end

group :profiling, :test do
  gem 'ruby-prof'
end

group :coverage do
  gem 'simplecov', require: 'simplecov'
  gem 'simplecov-rcov-text', require: 'simplecov-rcov-text'
end

group :development, :test, :staging do
  gem 'byebug', require: 'byebug'
  gem 'pry-rails'
  gem 'awesome_print'
end

group :development, :staging do
  gem 'mail_view', '~>2'
end

group :development, :test do
  gem 'pronto'
  gem 'pronto-brakeman', require: false
  gem 'pronto-fasterer', require: false
  gem 'pronto-rails_best_practices', require: false
  gem 'pronto-reek', require: false
  gem 'pronto-rubocop', require: false
  gem 'pronto-coffeelint', require: false
  gem 'pronto-eslint', require: false
end

group :development do
  gem 'thin'
  gem 'rails-dev-boost', github: 'thedarkone/rails-dev-boost'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'pry-nav'
  gem 'pry-doc', require: false
  gem 'pry-stack_explorer'
  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'mailcatcher'
  gem 'active_record_query_trace'
  gem 'parallel_tests', require: false

  gem 'rubycritic', require: false
  gem 'overcommit', require: false
  gem 'foreman', require: false
end

group :test do
  gem 'rspec', '2.14.1'
  gem 'codeclimate-test-reporter', '~> 0.4.4', require: false
  gem 'capybara'
  gem 'launchy'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', require: false
  gem 'cucumber'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'json_spec'
  gem 'minitest'
  gem 'mocha', require: false
  gem 'pickle', '~> 0.5.1'
  gem 'minitest-reporters', '~> 1.0.10'
  gem 'webmock', '1.17.4'
  gem 'shoulda'
  gem 'vcr'
  gem 'test_after_commit'
  gem 'rails-perftest'
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'ffaker', '~> 1.16'
end

gem 'mailman'
gem 'holidays', require: false

gem 'nearme', path: 'vendor/gems/nearme', require: false
gem 'sendle_api', path: 'vendor/gems/sendle_api', require: false
gem 'custom_attributes', path: 'vendor/gems/custom_attributes'

gem 'figaro'
gem 'wicked'
gem 'carmen'

gem 'i18n_data'

gem 'parser', require: false

gem 'routing-filter', '~> 0.5.0'

gem 'sprockets', '2.11.0'
gem 'sprockets-rails', '2.3.2'
gem 'cocoon'

gem 'redcarpet'
gem 'slack-notifier', require: false
gem 'colorize'
