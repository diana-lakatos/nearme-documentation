class Authentication::GoogleOauth2Provider < Authentication::BaseProvider

  META   = { name: "Google",
             url: "http://google.com/",
             auth: "OAuth 2" }

  def self.provider
    "google_oauth2"
  end

  def friend_ids
    # GooglePlus::Person.list(access_token: token)
    []
  end

  class Info < BaseInfo

    def initialize(raw)
      @raw          = raw
      @uid          = raw["id"].presence
      @username     = raw["username"]
      @email        = raw["email"]
      @name         = raw["name"]
      @first_name   = raw["first_name"]
      @last_name    = raw["last_name"]
      @description  = raw["bio"]
      @image_url    = ""
      @profile_url  = raw["link"]
      @website_url  = raw["website"]
      @location     = (raw["location"] || {})["name"]
      @verified     = raw['verified']
      @provider     = 'Google'
    end

  end

  private

    def connection
      @connection ||= Google::APIClient.new
    end

end
