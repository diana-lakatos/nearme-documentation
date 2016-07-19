ruby '2.2.4'

source 'http://rubygems.org'

gem 'rails', '4.2.4'
gem 'pg'
gem 'elasticsearch-persistence'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'patron'

gem 'redis'
gem 'redis-rails', '~> 4.0.0'
gem 'raygun4ruby'
gem 'liquid', '3.0.6'
gem 'active_model_serializers', '~> 0.8.1'
gem 'jsonapi-serializers', github: "mdyd-dev/jsonapi-serializers", branch: 'feature/namespace'
gem 'rabl'
gem 'carrierwave'
gem 'devise', '~> 3.5.0'
gem 'devise-token_authenticatable'
gem 'rack-throttle'

gem "rack-reverse-proxy", require: "rack/reverse_proxy", git: 'git@github.com:mdyd-dev/rack-reverse-proxy.git'

gem 'charlock_holmes', '~> 0.7.3'

gem 'aws-sdk'

gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-linkedin'
gem 'omniauth-instagram'
gem 'omniauth-saml'
gem 'omniauth-google-oauth2'
gem 'omniauth-github'

gem 'koala'
gem 'linkedin-oauth2', '~> 1.0'
gem 'omniauth-linkedin-oauth2'
gem 'twitter', '~> 5.5.1'
# Installing instagram from the master branch will fix ruby 2.2 circular dependency warning
gem 'instagram'
gem 'github_api'
gem 'google_plus'

gem 'reform', '~> 2.1.0'
gem 'tilt'


gem 'fog'
gem 'geocoder'
gem 'nearest_time_zone'
gem 'haml'
gem 'le'
gem 'mini_magick', '~> 4.0.1'
gem 'money-rails', github: 'RubyMoney/money-rails'
gem 'simple_form', '~> 3.1'
gem "paranoia", :github => "radar/paranoia", :branch => "rails4"
gem 'nested_form'


gem 'nokogiri', '~> 1.6.0'
gem 'hpricot'
gem 'amatch'
gem 'ri_cal'
gem 'ffaker', '~> 1.16'
gem 'draper'
gem 'counter_culture'
gem 'crummy'
gem 'ice_cube'
gem 'recurring_select', path: 'vendor/gems/recurring_select'
gem 'rails_autolink'

gem 'i18n-active_record',
    git: 'git://github.com/svenfuchs/i18n-active_record.git',
    require: 'i18n/active_record'

gem 'paper_trail', '5.2.0'

gem 'rack-rewrite', :require => 'rack/rewrite'

gem 'state_machine', '~> 1.2.0'
gem 'will_paginate'


gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'delayed_job_recurring'
gem 'daemons'
gem 'rdiscount'
gem 'attr_encrypted'
gem 'stripe'
gem 'paypal-sdk-rest', '~> 1.3.2'
gem 'paypal-sdk-merchant'
gem 'paypal-sdk-adaptivepayments'
gem 'braintree', '2.46.0'
gem 'faraday', '~> 0.9'
gem 'friendly_id', '~> 5.1'

gem 'chronic', '~> 0.9.1'


gem 'unicorn'

gem 'stringex'
gem 'ckeditor', github: 'galetahub/ckeditor'
gem 'orm_adapter', '~> 0.5.0' # needed for ckeditor, see https://github.com/galetahub/ckeditor/issues/375
gem 'sanitize'

gem 'useragent'
gem 'mixpanel', '4.0.2'
gem 'mixpanel_client'
gem 'voight_kampff'

gem 'rest-client'
gem 'jira-ruby', :require => 'jira'

gem 'gibbon'

gem 'twilio-ruby'
gem 'googl'


gem 'inherited_resources', '~> 1.6'

gem 'ranked-model'

gem 'after_commit_action'

gem 'premailer-rails'
gem 'addressable'
gem 'newrelic_rpm'
gem 'unicorn-worker-killer'

gem 'activemerchant'

gem 'shippo'

gem 'video_info'
gem 'spree_core', github: 'spree/spree', branch: '3-0-stable'
#gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-2-stable'

gem 'domainatrix'
gem 'store_base_sti_class', github: 'jcarreti/store_base_sti_class', branch: 'rails4-2'

gem 'acts-as-taggable-on', '~> 3.4'

gem 'validate_url'
gem 'ansi', require: false

group :profiling, :development do
  gem 'rack-mini-profiler', require: false
  gem 'flamegraph'
  gem 'bullet'
end

group :profiling, :test do
  gem 'ruby-prof'
end

group :coverage do
  gem 'simplecov', require: 'simplecov'
  gem 'simplecov-rcov-text', require: 'simplecov-rcov-text'
end

group :development, :test, :staging do
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'byebug', require: 'byebug'
end

group :development, :staging do
  gem 'mail_view', '~>2'
end

group :development do
  gem 'thin'
  gem 'rails-dev-boost', github: 'thedarkone/rails-dev-boost'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'quiet_assets'
  gem 'pry-nav'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'spring'
  gem 'spring-commands-cucumber'
  gem 'parallel_tests'
  gem 'mailcatcher'
  gem 'active_record_query_trace'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'rspec', '2.14.1'
  gem 'codeclimate-test-reporter', :require => false
  gem 'capybara', '2.4.4'
  gem 'launchy'
  gem 'capybara-webkit', '1.7.0'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', '~> 1.4.0', :require => false
  gem 'cucumber', '~> 1.3.0'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'json_spec'
  gem 'minitest'
  gem 'mocha', :require => false
  gem 'pickle', '~> 0.5.1'
  gem 'minitest-reporters', '~> 1.0.10'
  gem 'webmock', '1.17.4'
  gem 'shoulda'
  gem 'vcr'
  gem 'test_after_commit'
  gem 'rails-perftest'
  gem 'selenium-webdriver'
end
gem 'mailman'

gem 'nearme', path: 'vendor/gems/nearme'
gem 'custom_attributes', path: 'vendor/gems/custom_attributes'

gem 'figaro'
gem 'wicked'
gem 'carmen'

gem 'pry-rails'
gem 'awesome_print'
gem 'i18n_data'

gem 'parser'

gem 'routing-filter', '~> 0.5.0'

gem 'simple-navigation'

gem 'sprockets'
gem 'sprockets-rails'
gem 'cocoon'

gem 'redcarpet'
