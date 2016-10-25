require 'koala'

class Authentication::FacebookProvider < Authentication::BaseProvider
  META = {
    name: 'Facebook',
    url: 'http://facebook.com/',
    auth: 'OAuth 2'
  }.freeze

  def friend_ids
    @friend_ids ||= connection.get_connections('me', 'friends').collect { |f| f['id'].to_s }
  rescue Koala::Facebook::AuthenticationError
    raise ::Authentication::InvalidToken, $ERROR_INFO.inspect
  end

  def info
    @info ||= Info.new(connection.get_object('me'))
  rescue Koala::Facebook::AuthenticationError
    raise ::Authentication::InvalidToken
  end

  class Info < BaseInfo
    def initialize(raw)
      @raw          = raw
      @uid          = raw['id'].presence
      @username     = raw['username']
      @email        = raw['email']
      @name         = raw['name']
      @first_name   = raw['first_name']
      @last_name    = raw['last_name']
      @description  = raw['bio']
      @image_url    = "http://graph.facebook.com/#{raw['id']}/picture?type=large"
      @profile_url  = raw['link']
      @website_url  = raw['website']
      @location     = (raw['location'] || {})['name']
      @verified     = raw['verified']
      @provider     = 'Facebook'
    end
  end

  private

  def connection
    @connection ||= Koala::Facebook::API.new(token)
  end
end
