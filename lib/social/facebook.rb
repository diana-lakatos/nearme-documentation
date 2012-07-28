module Social
  module Facebook
    KEY    = ENV["FACEBOOK_KEY"]
    SECRET = ENV["FACEBOOK_SECRET"]

    def self.meta
      { name: "Facebook",
        url: "http://facebook.com/",
        auth: "OAuth 2" }
    end
    def self.meta_for_user(user)
      self.meta.merge(linked: self.user_linked?(user))
    end
    def self.user_linked?(user)
      user.linked_to?(provider_name)
    end
    def self.provider_name
      "facebook"
    end

    def self.get_user_info(token, secret = nil)
        require "open-uri"

        user_io  = open("https://graph.facebook.com/me?access_token=#{token}")
        raw_info = ActiveSupport::JSON.decode(user_io.read)
        uid      = raw_info["id"].to_s

        return [nil, nil] if uid.blank?

        info = {
          "nickname"    => raw_info["username"],
          "email"       => raw_info["email"],
          "name"        => raw_info["name"],
          "first_name"  => raw_info["first_name"],
          "last_name"   => raw_info["last_name"],
          "image"       => "http://graph.facebook.com/#{raw_info["id"]}/picture",
          "description" => raw_info["bio"],
          "urls"        => {
            "Facebook"  => raw_info["link"],
            "Website"   => raw_info["website"]
          },
          "location" => (raw_info["location"] || {})["name"],
          "verified" => raw_info["verified"]
        }

        [uid, info]
    end
  end
end
