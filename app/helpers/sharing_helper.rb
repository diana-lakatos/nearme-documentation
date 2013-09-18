module SharingHelper
  include Rails.application.routes.url_helpers

  def tweet_location_url(location_link)
    tweet_body = "Need a place to work? Check out our space on @DesksNearMe: #{location_link}"
    "https://twitter.com/intent/tweet?text=#{URI::escape(tweet_body)}"
  end
end
