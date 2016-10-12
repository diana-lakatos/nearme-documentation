require 'github_api'

class Authentication::GithubProvider < Authentication::BaseProvider
  META   = { name: 'GitHub',
             url: 'http://github.com/',
             auth: 'OAuth 2' }

  def friend_ids
    @friend_ids ||= (following.map(&:id) + followers.map(&:id)).uniq
  rescue
    raise ::Authentication::InvalidToken
  end

  def following
    @following ||= connection.users.followers.following
  rescue
    raise ::Authentication::InvalidToken
  end

  def followers
    @followers ||= connection.users.followers.list
  rescue
    raise ::Authentication::InvalidToken
  end

  def info
    @info ||= Info.new(connection.users.get)
  rescue
    raise ::Authentication::InvalidToken
  end

  def revoke
    instance = PlatformContext.current.instance
    github = Github.new basic_auth: "#{instance.encrypted_github_consumer_key}:#{instance.encrypted_github_consumer_secret}"
    github.oauth.app.delete instance.encrypted_github_consumer_key
  end

  class Info < BaseInfo
    def initialize(raw)
      @raw          = raw
      @uid          = raw['id'].presence
      @username     = raw['login']
      @email        = raw['email']
      @name         = raw['name']
      @description  = raw['bio']
      @image_url    = raw['avatar_url']
      @profile_url  = raw['url']
      @location     = raw['location']
      @provider     = 'GitHub'
    end
  end

  private

  def connection
    @connection ||= Github.new oauth_token: token
  end
end
