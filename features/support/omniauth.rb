module OmniauthHelper

  def mock_successful_authentication_with_provider(provider, options = {})
    options = options.reverse_merge(
      :provider => provider.downcase,
      :uid => '123545',
      :info => { 
        # those parameters need to correspond to information needed in app/helpers/authentications_helper
        :name => "#{provider} name",
        :image => "donthave.j[g",
        :nickname => 'omnitester', #for twitter
        :urls => {
          :public_profile => "htttp://myprofile.com", #linkedin
          :link => "htttp://myprofile.com",#facebook
        }
      }
    )
    OmniAuth.config.mock_auth[provider.downcase.to_sym] = OmniAuth::AuthHash.new(options)
  end

  def mock_unsuccessful_authentication_with_provider(provider, reason = "testing_invalid_credentials") 
    OmniAuth.config.logger = Rails.logger #otherwise the error goes to STDOUT
    OmniAuth.config.mock_auth[provider.downcase.to_sym] = reason.to_sym
  end


end

World(OmniauthHelper)
