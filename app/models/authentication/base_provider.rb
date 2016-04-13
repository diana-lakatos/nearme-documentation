class Authentication::BaseProvider
  attr_accessor :user, :token, :secret

  def initialize(attributes)
    self.user = attributes[:user]
    self.token = attributes[:token]
    self.secret = attributes[:secret]
  end

  def self.setup_proc
    lambda do |env|
      env['omniauth.strategy'].options[:consumer_key] = PlatformContext.current.instance.send(:"#{provider}_consumer_key").try(:strip)
      env['omniauth.strategy'].options[:consumer_secret] = PlatformContext.current.instance.send(:"#{provider}_consumer_secret").try(:strip)
      env['omniauth.strategy'].options[:client_id] = PlatformContext.current.instance.send(:"#{provider}_consumer_key").try(:strip)
      env['omniauth.strategy'].options[:client_secret] = PlatformContext.current.instance.send(:"#{provider}_consumer_secret").try(:strip)
    end
  end

  def self.new_from_authentication(authentication)
    new(user: authentication.user, token: authentication.token, secret: authentication.secret)
  end

  def self.provider
    provider_name = self.to_s.demodulize.split('Provider')[0].downcase
    raise NotImplementedError if provider_name == 'base'
    provider_name
  end

  def provider
    self.class.provider
  end

  def meta_for_user
    self.class::META.merge(linked: user.linked_to?(provider))
  end

  def is_oauth_1?
    self.class::META[:auth] == "OAuth 1.0a"
  end

  def connections
    @connections = User.joins(:authentications).where(authentications: {uid: self.friend_ids, provider: provider})
  rescue
    []
  end

  def new_connections
    @new_connections = connections.without(user.friends)
  end

  def revoke
    raise NotImplementedError
  end


  protected

  def connection
    raise NotImplementedError
  end

  def friend_ids
    raise NotImplementedError
  end

  class BaseInfo

    attr_accessor :raw, :provider, :uid, :username, :email, :name, :first_name, :last_name,
      :description, :location, :verified,
      :image_url, :profile_url, :website_url

    def to_hash
      {
        "nickname"    => username,
        "email"       => email,
        "name"        => name,
        "first_name"  => first_name,
        "last_name"   => last_name,
        "image"       => image_url,
        "description" => description,
        "urls"        => {
          provider    => profile_url,
          "Website"   => website_url
        },
        "location" => location,
        "verified" => verified
      }
    end

  end
end
