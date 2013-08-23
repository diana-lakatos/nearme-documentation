if Rails.env.production?
  Desk.configure do |config|
    config.support_email = "support@desksnear.me"
    config.subdomain = "desksnearme"
    config.consumer_key = "3NkiJdEvBBEiSpTbEGM7"
    config.consumer_secret = "wCacQKYOTEgerrvQXe4Q1OVynfgMca0fPhoIfYuI"
    config.oauth_token = "LCqW7oN1Fv0h2WbF0aN0"
    config.oauth_token_secret = "dZ3djyXZITc8jQgYgZSMuRJofYKkabRtphKHOQbC"
  end
end
