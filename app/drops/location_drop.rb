class LocationDrop < BaseDrop
  include ReservationsHelper
  include SharingHelper

  def initialize(location)
    @location = location
  end

  def name
    @location.name
  end

  def description
    @location.description
  end

  def url
    routes.location_listing_url(@location, @location.listings.first)
  end

  def tweet_url
    tweet_location_url(routes.location_url(@location))
  end

  def google_map_url
    "http://maps.google.com/?daddr=#{@location.address}"
  end

  def nearby_eateries_url
    "http://www.yelp.com/search?find_desc=eateries&find_loc=#{@location.address}&ns=1"
  end

  def weather_url
    "http://www.wunderground.com/cgi-bin/findweather/getForecast?bannertypeclick=htmlSticker&query=#{@location.address}&GO=GO"
  end


  def special_notes?
    !@location.special_notes.to_s.strip.empty?
  end

  def special_notes
    @location.special_notes.to_s.strip
  end

  def phone?
    @location.phone.present?
  end

  def phone
    @location.phone
  end 

  def facebook_img_url
    image_url('mailers/facebook.png').to_s
  end

  def twitter_img_url
    image_url('mailers/twitter.png').to_s
  end

  def linkedin_img_url
    image_url('mailers/linkedin.png').to_s
  end

  def facebook_social_share_url
    routes.new_location_social_share_url(@location, provider: 'facebook', track_email_event: true)
  end

  def twitter_social_share_url
    routes.new_location_social_share_url(@location, provider: 'twitter', track_email_event: true)
  end

  def linkedin_social_share_url
    routes.new_location_social_share_url(@location, provider: 'linkedin', track_email_event: true)
  end
end
