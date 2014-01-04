class Authentication::TwitterProvider < Authentication::BaseProvider

  KEY    = DesksnearMe::Application.config.twitter_key
  SECRET = DesksnearMe::Application.config.twitter_secret
  META   = { name: "Twitter",
             url: "http://twitter.com/",
             auth: "OAuth 1.0a" }

  def friend_ids
    begin
      @friend_ids ||= connection.friend_ids(count: 5000, stringify_ids: true).to_a
    rescue Twitter::Error::Unauthorized
      raise ::Authentication::InvalidToken
    rescue Twitter::Error::TooManyRequests
      Rails.logger.info "ignored friend_ids for #{@user.id} #{@user.name} due to Rate Limit Exceeded error"
    end
  end

  def info
    @info ||= begin
      Info.new(connection.user)
    rescue Twitter::Error::Unauthorized
      ::Authentication::InvalidToken
    end
  end

  class Info < BaseInfo

    def initialize(raw)
      @raw          = raw
      @uid          = raw.id
      @username     = raw.username
      @email        = raw['email']
      @name         = raw.name
      @description  = raw.description
      @image_url    = raw.profile_image_url(:original).to_s
      @profile_url  = raw.url.to_s
      @website_url  = raw.website.to_s
      @location     = raw.location
      @verified     = raw.verified
      @provider     = 'Twitter'
    end
  end

  private
  def connection
    @connection ||= Twitter::REST::Client.new(access_token: token,
                                              access_token_secret: secret,
                                              consumer_key: KEY,
                                              consumer_secret: SECRET)
  end

end
