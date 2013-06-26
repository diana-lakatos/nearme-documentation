Devise.setup do |config|
  config.mailer_sender = "support@desksnear.me"

  require 'devise/orm/active_record'
  config.case_insensitive_keys = [ :email ]

  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 10

  config.reconfirmable = true

  config.reset_password_within = 6.hours

  config.token_authentication_key = :token
  config.sign_out_via = :delete

  config.http_authenticatable_on_xhr = false

  # Sets up a Warden strategy to use for authenticating an admin as
  # another user in the system for using the website as that user.
  config.warden do |manager|
    manager.strategies.add(:admin_as_user) do
      def valid?
        Rails.logger.info session.inspect
        admin_as_user = session[:admin_as_user] || {}
        admin_as_user[:user_id].present? && admin_as_user[:admin_user_id].present?
      end

      def authenticate!
        u = User.find(session[:admin_as_user][:user_id])
        success!(u)
      end
    end

    manager.default_strategies(:scope => :user).push :admin_as_user
  end
end
