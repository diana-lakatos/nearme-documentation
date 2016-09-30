require 'instagram'

class Authentication::InstagramProvider < Authentication::BaseProvider

  META   = { name: "Instagram",
             url: "http://instagram.com/",
             auth: "OAuth 2" }

  def friend_ids
    begin
      @friend_ids ||= connection.user_follows.map(&:id)
    rescue Instagram::BadRequest, Instagram::NotFound
      raise ::Authentication::InvalidToken
    end
  end

  def info
    begin
      @info ||= Info.new(connection.user)
    rescue Instagram::BadRequest, Instagram::NotFound
      raise ::Authentication::InvalidToken
    end
  end

  class Info < BaseInfo

    def initialize(raw)
      @raw          = raw
      @uid          = raw.id
      @username     = raw.username
      @name         = raw.full_name
      @description  = raw.bio
      @image_url    = raw.profile_picture
      @profile_url  = "http://instagram.com/#{raw.username}"
      @website_url  = raw.website
      @provider     = 'Instagram'
    end

  end

  private

  def connection
    @connection ||= Instagram.client(access_token: token)
  end

end
