module AuthenticationsHelper

  class AuthProvider
    def initialize(auth)
      @auth = auth
      puts @auth
    end

    def name
      @auth['info']['name'].html_safe
    end

    def avatar_url
      @auth['info']['image'].html_safe
    end
  end

  class TwitterProvider < AuthProvider

    def connection_description
      "Connected via Twitter as <a href=\"http://twitter.com/#{@auth['info']['nickname']}\">@#{@auth['info']['nickname']}</a>".html_safe
    end
  end

  class LinkedinProvider < AuthProvider

    def connection_description
      "Connected via LinkedIn as <a href=\"#{@auth['info']['urls']['public_profile']}\">#{@auth['info']['name']}</a>".html_safe
    end
  end

  class FacebookProvider < AuthProvider

    def connection_description
      "Connected via FaceBook as <a href=\"#{@auth['info']['urls']['link']}\">#{@auth['info']['name']}</a>".html_safe
    end
  end

  # Return an object wrapping the omniauth provider which provides some view-model methods
  def user_auth_provider
    if session[:omniauth]
      type = case session[:omniauth]['provider']
      when 'twitter'
        TwitterProvider
      when 'facebook'
        FacebookProvider
      when 'linkedin'
        LinkedinProvider
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
