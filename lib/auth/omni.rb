module Auth
  class Omni
    attr_accessor :user

    def initialize(auth_params)
      @auth_params = auth_params
    end

    def create_user(google_analytics_id)
      user = User.new
      user.apply_omniauth(@auth_params)
      user.google_analytics_id = google_analytics_id
      user.save
    end

    def apply_avatar_if_empty
      user = authenticated_user
      if @auth_params['info']['image'] && !user.avatar.any_url_exists?
        user.remote_avatar_url = @auth_params['info']['image']
        user.avatar_versions_generated_at = Time.zone.now
        user.save!
      end
    end

    def remember_user!
      authenticated_user.remember_me!
    end

    def already_connected?(current_user)
      authentication && current_user && current_user.id != authentication.user.id
    end

    def create_authentication!(current_user)
      current_user.authentications.create!(:provider => provider,
                                           :uid => uid,
                                           :token => token,
                                           :secret => secret,
                                           :token_expires_at => expires_at,
                                           :token_expires => expires_at ? true : false,
                                           :token_expired => false)

      current_user.use_social_provider_image(@auth_params['info']['image'])
      current_user.save!
    end

    def update_token_info
      authentication.token_expires = expires_at ? true : false
      authentication.token_expired = false
      authentication.token_expires_at = expires_at
      authentication.token = token
      authentication.secret = secret
      authentication.save!
    end

    def email_taken_by_other_user?(current_user)
      if email = @auth_params['info']['email'].presence
        current_user.try(:email) != email && User.exists?(email: @auth_params['info']['email'])
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
      @authentication ||= Authentication.find_by_provider_and_uid(provider, uid)
    end

    def provider
      if @auth_params
        @auth_params['provider']
      else
        "native"
      end
    end

    def uid
      @auth_params['uid']
    end

    def token
      @auth_params['credentials']['token'] rescue nil
    end

    def secret
      @auth_params['credentials']['secret'] rescue nil
    end

    def expires_at
      Time.at(@auth_params['credentials']['expires_at']) rescue nil
    end
  end
end
