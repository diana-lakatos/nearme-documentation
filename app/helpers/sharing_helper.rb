module SharingHelper
  def tweet_location_url(location)
    tweet_body = "If you visit #{location.city} think about working out of our place! #{location_url(location)}"
    "https://twitter.com/intent/tweet?text=#{url_encode(tweet_body)}"
  end
end
