module Social
  module Linkedin
    KEY    = ENV["LINKEDIN_KEY"]
    SECRET = ENV["LINKEDIN_SECRET"]

    def self.meta
      { name: "LinkedIn",
        url: "http://linkedin.com/",
        auth: "OAuth 1.0a" }
    end
    def self.meta_for_user(user)
      self.meta.merge(linked: self.user_linked?(user))
    end
    def self.user_linked?(user)
      user.linked_to?(provider_name)
    end
    def self.provider_name
      "linkedin"
    end

    def self.get_user_info(token, secret)
      require "oauth"

      options = { :site               => "https://api.linkedin.com",
                  :authorize_path     => "/uas/oauth/authorize",
                  :request_token_path => "/uas/oauth/requestToken",
                  :access_token_path  => "/uas/oauth/accessToken" }

      consumer     = OAuth::Consumer.new(KEY, SECRET, options)
      access_token = OAuth::AccessToken.new(consumer, token, secret)

      fields   = ["id", "first-name", "last-name", "headline", "industry", "picture-url", "public-profile-url"].join(",")
      user_req = access_token.get("/v1/people/~:(#{fields})", "x-li-format" => "json")
      raw_info = ActiveSupport::JSON.decode(user_req.body)
      uid      = raw_info["id"].to_s

      return [nil, nil] if uid.blank?

      info = {
        "nickname"     => "#{raw_info["firstName"]} #{raw_info["lastName"]}",
        "first_name"  => raw_info["firstName"],
        "last_name"   => raw_info["lastName"],
        "name"        => "#{raw_info["firstName"]} #{raw_info["lastName"]}",
        "description" => raw_info["headline"],
        "image"       => raw_info["pictureUrl"],
        "industry"    => raw_info["industry"],
        "urls"        => {
          "public_profile" => raw_info["publicProfileUrl"]
        }
      }

      [uid, info]
    end
  end
end
