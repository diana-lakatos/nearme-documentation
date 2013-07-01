source 'http://rubygems.org'

gem 'rails', '3.2.13'
gem 'pg'
gem 'pg_search'

gem "RedCloth", "~> 4.2.9", :require => "redcloth"
gem 'airbrake'
gem 'active_model_serializers'
gem 'carrierwave'
gem 'decent_exposure'
gem 'devise'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-openid'
gem 'omniauth-facebook'
gem 'omniauth-linkedin'
gem 'fog'
gem 'foreman'
gem 'geocoder'
gem 'gravtastic'
gem 'sass'
gem 'haml'
gem 'mini_magick'
gem 'money-rails'
gem 'oauth'
gem 'rails3_acts_as_paranoid'
gem 'simple_form'
gem 'nokogiri'
gem 'amatch'

# Use edge to fix validation of nested attributes: https://github.com/bcardarella/client_side_validations/pull/505
gem 'client_side_validations', :git => "https://github.com/bcardarella/client_side_validations.git", :branch => '3-2-stable'

gem 'client_side_validations-simple_form'
gem 'state_machine'
gem 'texticle', '~> 2.0', :require => 'texticle/rails'
gem 'tweet-button'
gem 'will_paginate'
gem 'thinking-sphinx', '2.0.14', :require => 'thinking_sphinx'
gem 'ts-resque-delta', '1.2.4'
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
gem 'bootstrap-sass', '~> 2.3.0.0'
gem 'chronic'
gem 'chartjs-rails'

gem 'ey_config'

gem 'unicorn'
gem 'chameleon'

gem 'mixpanel'

gem 'gibbon'
gem 'dropbox-api'

gem 'twilio-ruby'
gem 'googl'

group :staging, :production do
  gem 'newrelic_rpm'
end

group :assets do
  gem 'handlebars_assets'
  gem 'mustachejs-rails'
  gem 'jquery-rails'
  gem 'chosen-rails'
  gem 'rails-backbone'
  gem 'jquery-fileupload-rails'
  gem 'uglifier'
end


group :development, :test, :staging do
  gem 'factory_girl_rails', '>=3.0.0'
end

group :development, :test do
  gem 'thin'
  gem 'shoulda', '3.3.2'
  gem 'shoulda-let', :require => 'shoulda/let'
  gem 'ffaker'
  gem 'factory_girl_rails', '>=3.0.0'
  gem 'email_spec'
  gem 'json_spec', '0.5.0'
  gem 'jasmine'
  gem 'debugger'
  gem 'pry-debugger'
end

group :development do
  gem "rails-erd"
  gem 'quiet_assets'
  gem 'mail_view'
  gem 'sextant'
  gem 'guard-minitest', :require => false
  gem 'guard-spork', :require => false
  gem 'guard-cucumber', :require => false
  gem 'spork-minitest', :git => 'https://github.com/Slashek/spork-minitest.git', :require => false
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem 'ruby-prof'
end
group :test do
  gem 'capybara', '~>1.1.2'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'minitest'
  gem 'mocha', :require => false
  gem 'pickle'
  gem 'simplecov', :require => false
  gem 'timecop'
  gem 'turn'
  gem 'webmock', :git => 'git://github.com/bblimke/webmock'
  gem 'simplecov', :require => false
  gem 'vcr'
end
