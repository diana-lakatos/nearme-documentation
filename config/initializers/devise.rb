# Setup our custom expiring URL token authentication strategy
require 'temporary_token_authenticatable'
require 'payment_token_authenticatable'
require 'devise/models/user_validatable'

Devise::TokenAuthenticatable.setup do |config|
  config.token_authentication_key = TemporaryTokenAuthenticatable::PARAMETER_NAME
end

Devise.setup do |config|
  config.mailer_sender = 'support@desksnear.me'

  require 'devise/orm/active_record'
  config.case_insensitive_keys = [:email]

  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 10

  config.reconfirmable = true

  config.reset_password_within = 6.hours

  config.sign_in_after_reset_password = true
  config.sign_out_via = :delete

  config.remember_for = 2.weeks
  config.http_authenticatable_on_xhr = false

  config.password_length = 6..128
  config.mailer = 'DeviseMailer'

  config.warden do |manager|
    manager.failure_app = CustomFailure
  end

  config.clean_up_csrf_token_on_authentication = false
end
