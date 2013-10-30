module OmniauthHelper

  def omniauth_image_url(url)
    @image_url = url
    stub_image_url
  end

  def create_user_for_provider(provider)
    @authentication = FactoryGirl.create(:authentication, {:uid => "123545", :provider => provider.downcase, :token => 'abcd'})
    @authentication.user
  end

  def mock_successful_authentication_with_provider(provider, options = {})
    omniauth_image_url("http://www.example.com/my_picture.jpg")
    options = options.reverse_merge(
      :provider => provider.downcase,
      :uid => '123545',
      :credentials => {
        :token => 'abcd'
      },
      :info => {
        # those parameters need to correspond to information needed in app/helpers/authentications_helper
        :name => "#{provider} name",
        :image => @image_url,
        :nickname => 'omnitester', #for twitter
        :urls => {
          :public_profile => "htttp://myprofile.com", #linkedin
          :link => "htttp://myprofile.com",#facebook
        }
      }
    )
    OmniAuth.config.mock_auth[provider.downcase.to_sym] = OmniAuth::AuthHash.new(options)
  end

  def stub_image_url(image_url = nil)
    image_url ||= @image_url
    stub_request(:get, image_url).to_return(:status => 200, :body => get_asset_image_path, :headers => {'Content-Type' => 'image/jpeg'})
  end

  def get_asset_image_path
    File.expand_path("../../../test/assets/foobear.jpeg", __FILE__)
  end

  def mock_unsuccessful_authentication_with_provider(provider, reason = "testing_invalid_credentials")
    OmniAuth.config.logger = Rails.logger #otherwise the error goes to STDOUT
    OmniAuth.config.mock_auth[provider.downcase.to_sym] = reason.to_sym
  end


end

World(OmniauthHelper)
