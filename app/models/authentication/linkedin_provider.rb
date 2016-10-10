class Authentication::LinkedinProvider < Authentication::BaseProvider
  META   = { name: 'LinkedIn',
             url: 'http://linkedin.com/',
             auth: 'OAuth 2.0' }
  FIELDS = ['id', 'first-name', 'last-name', 'headline', 'picture-url', 'public-profile-url', 'location']

  def self.setup_proc
    lambda do |env|
      instance = PlatformContext.current.instance
      env['omniauth.strategy'].options[:client_id] = instance.send(:"#{provider}_consumer_key").try(:strip)
      env['omniauth.strategy'].options[:client_secret] = instance.send(:"#{provider}_consumer_secret").try(:strip)
      env['omniauth.strategy'].options[:redirect_uri] = "https://#{instance.default_domain.name}/auth/#{provider}/callback"
    end
  end

  def friend_ids
    @friend_ids ||= connection.connections.all.collect(&:id)
  rescue LinkedIn::InvalidRequest, Faraday::ClientError
    []
  end

  def info
    @info ||= Info.new(connection.profile(fields: FIELDS))
    original_image = LinkedinImageRetrieverService.new(token).retrieve_original_image
    @info.image_url = original_image if original_image.present?

    @info
  rescue LinkedIn::InvalidRequest
    @info ||= Info.new(OpenStruct.new(id: nil, first_name: nil, last_name: nil, headline: nil, picture_url: nil, public_profile_url: nil, location: nil))
  end

  class Info < BaseInfo
    def initialize(raw)
      @raw          = raw
      @uid          = raw.id
      @first_name   = raw.first_name
      @last_name    = raw.last_name
      @name         = "#{@first_name} #{@last_name}"
      @description  = raw.headline
      @image_url    = raw.picture_url
      @profile_url  = raw.public_profile_url
      @location     = (raw.location || {})['name']
      @provider     = 'Linkedin'
    end
  end

  private

  def connection
    @connection ||= LinkedIn::API.new token
  end
end
