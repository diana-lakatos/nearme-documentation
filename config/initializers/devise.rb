# frozen_string_literal: true
# Setup our custom expiring URL token authentication strategy
require 'temporary_token_authenticatable'
require 'payment_token_authenticatable'

# Overwritten fix for using both modules: rememberable and timeoutable
# http://stackoverflow.com/questions/5034846/devise-remember-me-and-sessions
module Devise
  module Models
    module Timeoutable
      # Checks whether the user session has expired based on configured time.
      def timedout?(last_access)
        return false if remember_exists_and_not_expired? || !last_access.present?

        last_access <= self.class.timeout_in.ago
      end

      private

      def remember_exists_and_not_expired?
        return false unless respond_to?(:remember_expired?)
        remember_created_at && !remember_expired?
      end
    end
  end
end

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
