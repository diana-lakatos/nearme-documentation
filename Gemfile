source 'http://rubygems.org'

gem 'rails', '3.2.5'
gem 'pg'
gem 'pg_search'

gem "RedCloth", "~> 4.2.9", :require => "redcloth"
gem 'airbrake'
gem 'active_model_serializers', git: "git://github.com/josevalim/active_model_serializers.git"
gem 'carrierwave'
gem 'decent_exposure'
gem 'devise'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-openid'
gem 'fog'
gem 'foreman'
gem 'geocoder'
gem 'gravtastic'
gem 'sass'
gem 'haml'
gem 'mini_magick'
gem 'money-rails'
gem 'oauth'
gem 'paranoia'
gem 'simple_form'
gem 'state_machine'
gem 'texticle', '~> 2.0', :require => 'texticle/rails'
gem 'tweet-button'
gem 'will_paginate'
gem 'thinking-sphinx'
gem "compass-rails"
gem "coffee-rails"
gem "rdiscount"

gem 'jquery-rails'
gem 'sass-rails'
gem 'chronic'

group :staging, :production do
  gem 'flying-sphinx', '0.7.0'
  gem 'thin'
end

group :development do
  gem 'heroku'
  gem 'taps'
  gem 'sqlite3'
  gem "rails-erd"
  gem 'quiet_assets'
end

group :development, :test, :staging do
  gem 'factory_girl_rails', '>=3.0.0'
end

group :development, :test do
  gem 'shoulda'
  gem 'ffaker'
  gem 'shoulda'
  gem 'factory_girl_rails', '>=3.0.0'
  gem 'email_spec'
  gem 'json_spec', '0.5.0'
  gem 'ruby-debug19'
  gem 'jasmine'
  gem 'jasmine-headless-webkit', '0.9.0.rc.2'
end

group :test do
  gem 'autotest'
  gem 'capybara', '1.1.2'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'minitest'
  gem 'mocha'
  gem 'pickle'
  gem 'simplecov', :require => false
  gem 'timecop'
  gem 'turn'
  gem 'webmock', :git => 'git://github.com/bblimke/webmock'
end

group :production do
  gem 'newrelic_rpm'
end
