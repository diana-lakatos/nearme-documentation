if Rails.env.production?
  Desk.configure do |config|
    config.support_email = "support@desksnear.me"
    config.subdomain = "desksnearme"
    config.consumer_key = "3NkiJdEvBBEiSpTbEGM7"
    config.consumer_secret = "wCacQKYOTEgerrvQXe4Q1OVynfgMca0fPhoIfYuI"
    config.oauth_token = "LCqW7oN1Fv0h2WbF0aN0"
    config.oauth_token_secret = "dZ3djyXZITc8jQgYgZSMuRJofYKkabRtphKHOQbC"
  end

  # 14-day trial since 2013-07-29 ;-) replace with a logger later?
elsif Rails.env.staging?
  Desk.configure do |config|
    config.support_email = "maciej@desksnear.me"
    config.subdomain = "anamaweb"
    config.consumer_key = "hL6k8W43Pas8aC7UMvc2"
    config.consumer_secret = "Gq4JIJaaniqQTEW12QVkQ847xd8TVpWKFxkhI5If"
    config.oauth_token = "Bia2FWlxCeDibWfBuU6B"
    config.oauth_token_secret = "hJYdFEOP3zAO0BM6uW5ps6NTZGti84Cy7AFBp8ac"
  end
end
