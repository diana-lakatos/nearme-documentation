module Auth
  class Omni
    attr_accessor :user

    def initialize(auth_params)
      @auth_params = auth_params
    end

    def create_user
      user = User.new
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
      current_user.authentications.create!(:provider => @auth_params['provider'], :uid => @auth_params['uid'])
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
      @authentication ||= Authentication.find_by_provider_and_uid(@auth_params['provider'],
                                                                  @auth_params['uid'])
    end

  end
end
