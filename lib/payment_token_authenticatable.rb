module PaymentTokenAuthenticatable
  # This is the parameter name that is matched in the URL as the login token.
  PARAMETER_NAME = 'payment_token'

  class Strategy < Devise::Strategies::Authenticatable
    def authenticate!
      user, params = User::PaymentTokenVerifier.find_token(payment_token)

      if user
        success!(user)
      else
        pass
      end
    end

    def valid?
      temporary_token.present?
    end

    private

    def payment_token
      params[PARAMETER_NAME]
    end
  end
end

Warden::Strategies.add(:payment_token_authenticatable, PaymentTokenAuthenticatable::Strategy)
Devise.add_module :payment_token_authenticatable, strategy: true

# Once a user session is stored, the authentication strategies don't fire.
# Therefore, if we detect a temporary token based login from a link, we
# need to clear any existing sessions.
Warden::Manager.on_request do |proxy, *_args|
  # Match the presence of a query parameter matching our token parameter
  if proxy.env['QUERY_STRING'] =~ /(^|\&)#{PaymentTokenAuthenticatable::PARAMETER_NAME}=/
    proxy.logout(:user)
  end
end
