source 'http://rubygems.org'

gem 'rails', '3.2.14'
gem 'pg'

gem 'raygun4ruby'
gem "liquid"
gem 'active_model_serializers'
gem 'carrierwave'
gem 'devise', "~> 2.2"
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-linkedin'
gem 'fog'
gem 'geocoder'
gem 'nearest_time_zone'
gem 'sass'
gem 'haml'
gem 'le'
gem 'mini_magick'
gem 'money-rails'
gem 'rails3_acts_as_paranoid'
gem 'simple_form'
gem 'nokogiri'
gem 'amatch'
gem 'ri_cal'
gem 'ffaker'
gem 'draper'

gem 'paper_trail'

gem 'rack-rewrite', :require => 'rack/rewrite'

gem 'state_machine'
gem 'will_paginate'
gem 'resque'
gem "compass-rails"
# when we upgrade compass, we should change it into animate - actually they plan to add this to compass by default
gem 'animation'
gem "coffee-rails"
gem 'delayed_job_active_record'
gem "rdiscount"
gem 'stripe'
gem 'friendly_id'

gem 'sass-rails'
gem 'bootstrap-sass', '~> 2.3.1.0'
gem 'chronic'
gem 'chartjs-rails'
gem 'jcrop-rails'
gem 'fastimage'

gem 'ey_config'

gem 'unicorn'
gem 'chameleon'

gem 'useragent'
gem 'mixpanel'
gem 'mixpanel_client'

gem 'rest-client'

gem 'gibbon'
gem 'dropbox-api'

gem 'twilio-ruby'
gem 'googl'

gem 'jquery-rails'
gem 'jquery-fileupload-rails'
gem 'chosen-rails'

gem 'inherited_resources'
gem "historyjs-rails"

gem 'ranked-model'

gem 'desk'
gem 'filepicker-rails'

group :staging, :production do
  gem 'newrelic_rpm'
end

group :assets do
  gem 'uglifier', "~>2.1.0"
end

group :development, :test, :staging do
  gem 'factory_girl_rails', '>=3.0.0'
end

group :development, :test do
  gem 'thin'
  gem 'shoulda'
  gem 'email_spec'
  gem 'json_spec'
end

group :development do
  gem 'quiet_assets'
  gem 'mail_view'
  gem 'guard-minitest', :require => false
  gem 'guard-spork', :require => false
  gem 'guard-cucumber', :require => false
  gem 'spork-minitest', :git => 'https://github.com/Slashek/spork-minitest.git', :require => false
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'ruby-prof'
end
group :test do
  gem 'capybara', '~>2'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', :require => false
  gem 'cucumber', '~> 1.2.5'
  gem 'database_cleaner'
  gem 'minitest'
  gem 'mocha', :require => false
  gem 'pickle'
  gem 'timecop'
  gem 'turn'
  gem 'webmock'
  gem 'simplecov', :require => false
  gem 'vcr'
end
