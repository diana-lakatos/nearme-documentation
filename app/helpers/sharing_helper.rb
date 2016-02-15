module SharingHelper

  def tweet_location_url(location_link)
    tweet = "Check out our #{platform_context.instance.bookable_noun}"
    tweet << " on @#{platform_context.twitter_handle}" if platform_context.twitter_handle
    tweet_body = "#{tweet}: #{location_link}"
    "https://twitter.com/intent/tweet?text=#{URI::escape(tweet_body)}"
  end

  def tweet_listing_url(listing)
    tweet = "Check out our #{listing.transactable_type.translated_bookable_noun}"
    tweet << " on @#{platform_context.twitter_handle}" if platform_context.twitter_handle
    tweet_body = "#{tweet}: #{listing.decorate.show_url}"
    "https://twitter.com/intent/tweet?text=#{URI::escape(tweet_body)}"
  end
end
