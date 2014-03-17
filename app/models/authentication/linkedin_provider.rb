class Authentication::LinkedinProvider < Authentication::BaseProvider

  META   = { name: "LinkedIn",
             url: "http://linkedin.com/",
             auth: "OAuth 1.0a" }
  FIELDS = ["id", "first-name", "last-name", "headline", "industry", "picture-url", "public-profile-url", "location"]

  def friend_ids
    begin
      @friend_ids ||= connection.connections.all.collect(&:id)
    rescue LinkedIn::Errors::AccessDeniedError
      raise ::Authentication::InvalidToken
    end
  end

  def info
    begin
      @info ||= Info.new(connection.profile(fields: FIELDS))
    rescue LinkedIn::Errors::AccessDeniedError
      raise ::Authentication::InvalidToken
    end
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
    @connection ||= LinkedIn::Client.new.tap{|c| c.set_access_token(token)}
  end

end
