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
      current_user.authentications.create!(:provider => provider, :uid => uid)
      current_user.use_social_provider_image(@auth_params['info']['image'])
      current_user.save!
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

  end
end
