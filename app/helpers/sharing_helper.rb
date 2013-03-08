module SharingHelper
  def tweet_location_url(location)
    tweet_body = "Need a place to work? Check out our space on @DesksNearMe: #{location_url(location)}"
    "https://twitter.com/intent/tweet?text=#{url_encode(tweet_body)}"
  end
end
