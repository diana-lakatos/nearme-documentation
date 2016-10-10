class LocationDrop < BaseDrop
  include AvailabilityRulesHelper
  include ReservationsHelper
  include SharingHelper
  include GoogleMapsHelper
  include LocationsHelper

  attr_reader :location

  # id
  #   numeric identifier of the location
  # slug
  #   user friendly identifier of the location
  # listings
  #   array of listings for this location
  # lowest_price
  #   lowest price listing for this location
  # lowest_full_price
  #   lowest price listing for this location (i.e. including service fees and mandatory additional charges)
  # name
  #   name of this location as string
  # description
  #   description of this location as string
  # location_type_name
  #   name of the location type to which location belongs as a string
  # phone
  #   phone number for this location as string
  # street
  #   street name for this location as string
  # city
  #   city name for this location as string
  # suburb
  #   suburb name for this location as string
  # company
  #   company object for this location
  # administrator
  #   user object returning current administrator for this location
  # creator
  #   user object returning creator of this location
  # address
  #   address for this location as string
  # latitude
  #   latitude for this location as a floating point number
  # longitude
  #   longitude for this location as a floating point number
  # postcode
  #   post code for this location
  # country
  #   country for this location
  # state
  #   state for this location
  delegate :id, :slug, :listings, :lowest_price, :name, :description, :phone, :street, :city, :suburb, :company, :address, :latitude, :longitude, :creator, :administrator, :updated_at, :postcode,
           :country, :state, :lowest_full_price, :to_key, :model_name, to: :location

  def initialize(location)
    @location = location
  end

  def class_name
    'Location'
  end

  # When the location is available for booking as a string
  def availability
    pretty_availability_sentence(@location.availability).to_s
  end

  # Url for the location in the application
  def url
    @location.listings.first.try(:decorate).try(:show_path)
  end

  # fully qualified url
  def full_url
    urlify(url)
  end

  # array of photo items; each photo item is a hash with the keys being:
  #   space_listing - photo having a dimension of the space_listing type
  #   golden - photo having a dimension of the golden type
  #   large - photo having a dimension of the large type
  #   listing_name - listing name for the photo
  #   caption - caption of the photo
  def photos
    location.photos_metadata
  end

  # Url to this location in Google Maps
  def google_map_url
    "http://maps.google.com/?daddr=#{@location.address}"
  end

  # Nearby eateries for this location from Yelp
  def nearby_eateries_url
    "http://www.yelp.com/search?find_desc=eateries&find_loc=#{@location.address}&ns=1"
  end

  # Url to the weather information for this location at Weather Underground
  def weather_url
    "http://www.wunderground.com/cgi-bin/findweather/getForecast?bannertypeclick=htmlSticker&query=#{@location.address}&GO=GO"
  end

  # HTML-formatted address for this location
  def formatted_address
    location_format_address(location.address)
  end

  # returns true if the address has multiple parts
  def display_parts_of_address?
    address.split(',').length > 1
  end

  # returns the first part of the address as a string
  def address_formatted
    address.split(',')[0]
  end

  # returns the additional parts of the address as a string
  def address_formatted_additional
    parts = address.split(',')
    ", #{parts[1, parts.length].join(', ')}"
  end

  # route url to this location on Google Maps
  def google_maps_route
    google_maps_route_url(to: location.address, from: '')
  end

  # returns true if the location has special notes added to it
  def special_notes?
    !@location.special_notes.to_s.strip.empty?
  end

  # returns the special notes for this location
  def special_notes
    @location.special_notes.to_s.strip
  end

  # returns true if the location has a phone number added
  def phone?
    phone.present?
  end

  # formatted string containing the company name and parts of the location
  def default_title
    location.name
    location_compound_address = [
      location.company.name,
      location.suburb,
      location.city,
      location.country == 'United States' ? location.state_code : location.country
    ].reject(&:blank?).join(', ')

    "#{location.name} | #{location_compound_address}"
  end

  def location_type_name
    @location.location_type.try(:name)
  end

  # names of amenities for this location
  def amenities
    @location.amenities.order('name ASC').pluck(:name)
  end
end
