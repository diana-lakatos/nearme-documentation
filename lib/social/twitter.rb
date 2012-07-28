module Social
  module Twitter
    KEY    = ENV["TWITTER_KEY"]
    SECRET = ENV["TWITTER_SECRET"]

    def self.meta
      { name: "Twitter",
        url: "http://twitter.com/",
        auth: "OAuth 1.0a" }
    end
    def self.meta_for_user(user)
      self.meta.merge(linked: self.user_linked?(user))
    end
    def self.user_linked?(user)
      user.linked_to?(provider_name)
    end
    def self.provider_name
      "twitter"
    end

    def self.get_user_info(token, secret)
      require "oauth"

      options = { :site           => "https://api.twitter.com",
                  :authorize_path => "/oauth/authenticate" }

      consumer     = OAuth::Consumer.new(KEY, SECRET, options)
      access_token = OAuth::AccessToken.new(consumer, token, secret)

      user_req = access_token.get("/1/account/verify_credentials.json")
      raw_info = ActiveSupport::JSON.decode(user_req.body)
      uid      = raw_info["id"].to_s

      return [nil, nil] if uid.blank?

      info = {
        "nickname"    => raw_info["screen_name"],
        "name"        => raw_info["name"],
        "location"    => raw_info["location"],
        "image"       => raw_info["profile_image_url"],
        "description" => raw_info["description"],
        "urls"        => {
          "Website" => raw_info["url"],
          "Twitter" => "http://twitter.com/#{raw_info["screen_name"]}",
        }
      }

      [uid, info]
    end
  end
end
