# frozen_string_literal: true
class LocationDrop < BaseDrop
  include AvailabilityRulesHelper
  include ReservationsHelper
  include SharingHelper
  include GoogleMapsHelper
  include LocationsHelper

  # @return [LocationDrop]
  attr_reader :location

  # @!method id
  #   @return [Integer] numeric identifier of the location
  # @!method slug
  #   User friendly identifier of the location
  #   @return (see Location#slug)
  # @!method listings
  #   @return [Array<Transactable>] Array of listings for this location
  # @!method lowest_price
  #   @return [Transactable::PricingDrop] object corresponding to the lowest available pricing for this transactable
  # @!method name
  #   Name of this location
  #   @return (see Location#name)
  # @!method description
  #   Description of this location
  #   @return (see Location#description)
  # @!method phone
  #   @return [String] phone number for this location
  # @!method street
  #   Street name for this location
  #   @return (see Location#street)
  # @!method city
  #   City name for this location
  #   @return (see Location#city)
  # @!method suburb
  #   Suburb name for this location
  #   @return (see Location#suburb)
  # @!method company
  #   @return [CompanyDrop] Company object for this location
  # @!method address
  #   Address for this location
  #   @return (see Location#address)
  # @!method latitude
  #   Latitude for this location
  #   @return (see Location#latitude)
  # @!method longitude
  #   Longitude for this location
  #   @return (see Location#longitude)
  # @!method creator
  #   @return [UserDrop] User who created this location
  # @!method administrator
  #   @return [UserDrop] User who administers this location
  # @!method updated_at
  #   Last time when the location was updated
  #   @return [DateTime]
  # @!method postcode
  #   Post code for this location
  #   @return (see Location#postcode)
  # @!method country
  #   Country for this location
  #   @return (see Location#country)
  # @!method state
  #   State for this location
  #   @return (see Location#state)
  # @!method lowest_full_price
  #   @return [Transactable::PricingDrop] lowest price for this location (i.e. including service fees and mandatory additional charges)
  # @!method to_key
  #   @return [Array<Integer>] array of key attributes for the object
  delegate :id, :slug, :listings, :lowest_price, :name, :description, :phone, :street, :city, :suburb, :company, :address, :latitude, :longitude, :creator, :administrator, :updated_at, :postcode, :country, :state, :lowest_full_price, :to_key, :model_name, to: :location

  def initialize(location)
    @location = location
  end

  # @return [String] 'Location' - the class name
  def class_name
    'Location'
  end

  # @return [String] when the location is available for booking as a
  #   string in a pretty format
  def availability
    pretty_availability_sentence(@location.availability).to_s
  end

  # @return [String] path to the first listing in the location
  def url
    @location.listings.first.try(:decorate).try(:show_path)
  end

  # @return [String] url to the first listing in the location
  def full_url
    urlify(url)
  end

  # @return [Array<Hash<String, String>>] array of photo items; each photo item is a hash
  #   with the keys being:
  #     listing_name - listing name for the photo
  #     caption - caption of the photo
  #     original - url to the original image
  #     fullscreen - url to the image with the fullscreen size
  #     space_listing - url to the image with the space_listing size
  #     golden - url to the image with the golden size
  #     large - url to the image with the large size
  def photos
    location.photos_metadata
  end

  # @return [String] url to this location in Google Maps
  def google_map_url
    "http://maps.google.com/?daddr=#{@location.address}"
  end

  # @return [String] nearby eateries for this location from Yelp
  def nearby_eateries_url
    "http://www.yelp.com/search?find_desc=eateries&find_loc=#{@location.address}&ns=1"
  end

  # @return [String] url to the weather information for this location at Weather Underground
  def weather_url
    "http://www.wunderground.com/cgi-bin/findweather/getForecast?bannertypeclick=htmlSticker&query=#{@location.address}&GO=GO"
  end

  # @return [String] HTML-formatted address for this location
  def formatted_address
    location_format_address(location.address)
  end

  # @return [Boolean] whether the address has multiple parts
  def display_parts_of_address?
    address.split(',').length > 1
  end

  # @return [String] the first part of the address
  def address_formatted
    address.split(',')[0]
  end

  # @return [String] the additional parts of the address (after the first part)
  def address_formatted_additional
    parts = address.split(',')
    ", #{parts[1, parts.length].join(', ')}"
  end

  # @return [String] route url to this location on Google Maps
  def google_maps_route
    google_maps_route_url(to: location.address, from: '')
  end

  # @return [Boolean] whether the location has special notes added to it
  def special_notes?
    !@location.special_notes.to_s.strip.empty?
  end

  # @return [String] the special notes for this location
  def special_notes
    @location.special_notes.to_s.strip
  end

  # @return [Boolean] whether the location has a phone number added
  def phone?
    phone.present?
  end

  # @return [String] formatted string containing the company name and parts of the location
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

  # @return [String] the location type, e.g. 'Business' etc.
  def location_type_name
    @location.location_type.try(:name)
  end
end
