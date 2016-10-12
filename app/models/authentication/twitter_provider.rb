require 'twitter'

class Authentication::TwitterProvider < Authentication::BaseProvider
  SETUP_PROC = lambda do |env|
    env['omniauth.strategy'].options[:consumer_key] = PlatformContext.current.instance.twitter_consumer_key
    env['omniauth.strategy'].options[:consumer_secret] = PlatformContext.current.instance.twitter_consumer_secret
  end
  META   = { name: 'Twitter',
             url: 'http://twitter.com/',
             auth: 'OAuth 1.0a' }

  def friend_ids
    @friend_ids ||= connection.friend_ids(count: 5000, stringify_ids: true).to_a
  rescue Twitter::Error::Unauthorized
    raise ::Authentication::InvalidToken
  rescue Twitter::Error::TooManyRequests
    Rails.logger.info "ignored friend_ids for #{@user.id} #{@user.name} due to Rate Limit Exceeded error"
  end

  def info
    @info ||= Info.new(connection.user)
  rescue Twitter::Error::Unauthorized
    raise ::Authentication::InvalidToken
  rescue Twitter::Error::TooManyRequests
    Rails.logger.info "ignored friend_ids for #{@user.id} #{@user.name} due to Rate Limit Exceeded error"
  end

  class Info < BaseInfo
    def initialize(raw)
      @raw          = raw
      @uid          = raw.id
      @username     = raw.username
      @name         = raw.name
      @description  = raw.description
      @image_url    = raw.profile_image_url(:original).to_s
      @profile_url  = raw.url.to_s.presence
      @website_url  = raw.website.to_s.presence
      @location     = raw.location
      @verified     = raw.verified
      @provider     = 'Twitter'
    end
  end

  private

  def connection
    @connection ||= Twitter::REST::Client.new(access_token: token,
                                              access_token_secret: secret,
                                              consumer_key: PlatformContext.current.instance.twitter_consumer_key,
                                              consumer_secret: PlatformContext.current.instance.twitter_consumer_secret)
  end
end
