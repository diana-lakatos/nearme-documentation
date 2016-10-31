module OmniauthHelper
  def create_user_for_provider(provider)
    @authentication = FactoryGirl.create(:authentication, uid: '123545', provider: provider.downcase, token: 'abcd')
    @authentication.user
  end

  def mock_successful_authentication_with_provider(provider, options = {})
    stub_image_url('http://www.example.com/my_picture.jpg')
    options = options.reverse_merge(
      provider: provider.downcase,
      uid: '123545',
      credentials: {
        token: 'abcd'
      },
      info: {
        # those parameters need to correspond to information needed in app/helpers/authentications_helper
        name: "#{provider} name",
        image: 'http://www.example.com/my_picture.jpg',
        nickname: 'omnitester', # for twitter
        urls: {
          public_profile: 'htttp://myprofile.com', # linkedin
          link: 'htttp://myprofile.com',  # facebook
        }
      }
    )
    OmniAuth.config.mock_auth[provider.downcase.to_sym] = OmniAuth::AuthHash.new(options)
  end

  def stub_image_url(image_url, options = {})
    image_path = options[:file] || Rails.root.join('test', 'assets', 'foobear.jpeg')
    stub_request(:get, image_url).to_return(status: 200, body: File.read(image_path), headers: { 'Content-Type' => 'image/jpeg' })
    stub_request(:head, image_url).to_return(status: 200, body: Rails.root.join('test', 'assets', 'foobear.jpeg'), headers: { 'Content-Type' => 'image/jpeg' })
  end

  def mock_unsuccessful_authentication_with_provider(provider, reason = 'testing_invalid_credentials')
    OmniAuth.config.logger = Rails.logger # otherwise the error goes to STDOUT
    OmniAuth.config.mock_auth[provider.downcase.to_sym] = reason.to_sym
  end
end

World(OmniauthHelper)
