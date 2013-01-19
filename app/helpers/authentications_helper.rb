module AuthenticationsHelper

  class AuthProvider
    def initialize(auth)
      @auth = auth
    end

    def name
      @auth['info']['name']
    end

    def avatar_url
      @auth['info']['image']
    end

    def connection_description
      "Connected via #{title} as <a href='#{destination_url}'>#{display_url}</a>".html_safe
    end
  end

  class TwitterProvider < AuthProvider

    def destination_url
      "http://twitter.com/#{@auth['info']['nickname']}"
    end

    def display_url
      "@#{@auth['info']['nickname']}"
    end

    def title
      "Twitter"
    end
  end

  class LinkedinProvider < AuthProvider

    def destination_url
      "#{@auth['info']['urls']['public_profile']}"
    end

    def display_url
      "#{@auth['info']['name']}"
    end

    def title
      "LinkedIn"
    end

  end

  class FacebookProvider < AuthProvider

    def destination_url
      "#{@auth['info']['urls']['link']}"
    end

    def display_url
      "#{@auth['info']['name']}"
    end

    def title
      "FaceBook"
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
