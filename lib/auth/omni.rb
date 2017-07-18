module Auth
  class Omni
    attr_accessor :user

    def initialize(auth_params)
      @auth_params = auth_params || {}
      @auth_params['info'] ||= {}
      @auth_params['credentials'] ||= {}
    end

    def create_user(role)
      user = User.new
      user.force_profile = role
      user.apply_omniauth(@auth_params)
      user.save
    end

    def remember_user!
      authenticated_user.remember_me!
    end

    def already_connected?(current_user)
      authentication && current_user && current_user.id != authentication.user.id
    end

    def create_authentication!(current_user)
      current_user.authentications.create!(provider: provider,
                                           uid: uid,
                                           token: token,
                                           secret: secret,
                                           token_expires_at: expires_at,
                                           token_expires: expires_at ? true : false,
                                           token_expired: false)
      current_user.save!(validate: false)
    end

    def update_token_info
      authentication.token_expires = expires_at ? true : false
      authentication.token_expired = false
      authentication.token_expires_at = expires_at
      authentication.token = token
      authentication.secret = secret
      authentication.save!
    end

    def email
      @email ||= @auth_params['info']['email']
    end

    def email_taken_by_other_user?(current_user)
      if email.present?
        user = User.find_by(email: email)
        current_user.try(:email) != email && user.present? && Authentication.where('user_id = ? AND provider = ?', user.id, provider).count.zero?
      else
        false
      end
    end

    def authenticated_user
      if user
        user
      elsif authentication
        authentication.user
      else
        raise 'No user specified!'
      end
    end

    def authentication
      @authentication ||= Authentication.find_by(provider: provider, uid: uid)
    end

    def provider
      @auth_params['provider'] || 'native'
    end

    def uid
      @auth_params['uid']
    end

    def token
      @auth_params['credentials']['token'].presence || @auth_params['extra']['raw_info']['enterprise_id'] .presence || @auth_params['extra']['raw_info']['CustID']
    end

    def secret
      @auth_params['credentials']['secret']
    end

    def expires_at
      # FIXME: https://github.com/decioferreira/omniauth-linkedin-oauth2/issues/10
      if provider == 'linkedin'
        Time.zone.now + 60.days
      else
        begin
          Time.at(@auth_params['credentials']['expires_at'])
        rescue
          nil
        end
      end
    end
  end
end
