class LocationDrop < BaseDrop

  include AvailabilityRulesHelper
  include ReservationsHelper
  include SharingHelper
  include GoogleMapsHelper
  include LocationsHelper

  attr_reader :location
  delegate :name, :description, :phone, :street, :city, :suburb, :company, :address, :latitude, :longitude, to: :location

  def initialize(location)
    @location = location
  end

  def availability
    pretty_availability_sentence(@location.availability).to_s
  end

  def url
    routes.location_path(@location, @location.listings.first)
  end

  def tweet_url
    tweet_location_path(routes.location_url(@location))
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

  def formatted_address
    location_format_address(location.address)
  end

  def display_parts_of_address?
    address.split(',').length > 1
  end

  def address_formatted
    address.split(',')[0]
  end

  def address_formatted_additional
    parts = address.split(',')
    ", #{parts[1, parts.length].join(', ')}"
  end

  def google_maps_route
    google_maps_route_url(to: location.address, from: "")
  end

  def special_notes?
    !@location.special_notes.to_s.strip.empty?
  end

  def special_notes
    @location.special_notes.to_s.strip
  end

  def phone?
    phone.present?
  end

  def facebook_img_url
    image_url('mailers/facebook.png')
  end

  def twitter_img_url
    image_url('mailers/twitter.png')
  end

  def linkedin_img_url
    image_url('mailers/linkedin.png')
  end

  def facebook_social_share_url
    routes.new_location_social_share_path(@location, provider: 'facebook', track_email_event: true)
  end

  def twitter_social_share_url
    routes.new_location_social_share_path(@location, provider: 'twitter', track_email_event: true)
  end

  def linkedin_social_share_url
    routes.new_location_social_share_path(@location, provider: 'linkedin', track_email_event: true)
  end

  def default_title
    [location.company.name, location.suburb, location.city, location.country == "United States" ? location.state_code : location.country].reject(&:blank?).join(' - ')
  end
end
