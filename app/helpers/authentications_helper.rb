module AuthenticationsHelper

  class AuthProvider
    def initialize(auth)
      @auth = auth
    end

    def name
      @auth['info']['name']
    end
  end

  class TwitterProvider < AuthProvider
    def avatar_url
      "http://api.twitter.com/1/users/profile_image?screen_name=#{@auth['info']['nickname']}&size=normal"
    end

    def connection_description
      "Connected via Twitter as <a href=\"http://twitter.com/#{@auth['info']['nickname']}\">@#{@auth['info']['nickname']}</a>".html_safe
    end
  end

  # Return an object wrapping the omniauth provider which provides some view-model methods
  def user_auth_provider
    if session[:omniauth]
      type = case session[:omniauth]['provider']
      when 'twitter'
        TwitterProvider
      end

      type.new(session[:omniauth]) if type
    end
  end

  def provider_auth_url(provider)
    url = "/auth/#{provider}"
    url += "?wizard=#{params[:wizard]}" if params[:wizard]
    url
  end
end
