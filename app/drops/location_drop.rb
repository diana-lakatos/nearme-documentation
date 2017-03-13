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
  #   @return [String] User friendly identifier of the location
  # @!method listings
  #   @return [Array<Transactable>] Array of listings for this location
  # @!method lowest_price
  #   @return [Transactable::PricingDrop] object corresponding to the lowest available pricing for this transactable
  # @!method name
  #   @return [String] Name of this location
  # @!method description
  #   @return [String] Description of this location
  # @!method phone
  #   @return [String] phone number for this location
  # @!method street
  #   @return [String] Street name for this location
  # @!method city
  #   @return [String] City name for this location
  # @!method suburb
  #   @return [String] Suburb name for this location
  # @!method company
  #   @return [CompanyDrop] Company object for this location
  # @!method address
  #   @return [String] Address for this location
  # @!method latitude
  #   @return [Float] Latitude for this location
  # @!method longitude
  #   @return [Float] Longitude for this location
  # @!method creator
  #   @return [UserDrop] User who created this location
  # @!method administrator
  #   @return [UserDrop] User who administers this location
  # @!method updated_at
  #   Last time when the location was updated
  #   @return [DateTime]
  # @!method postcode
  #   @return [String] Post code for this location
  # @!method country
  #   @return [String] Country name for this location
  # @!method state
  #   @return [String] State name for this location
  # @!method lowest_full_price
  #   @return [Transactable::PricingDrop] lowest price for this location (i.e. including service fees and mandatory additional charges)
  # @!method to_key
  #   @return [Array<Integer>] array of key attributes for the object
  # @!method impressions_count
  #   @return [Integer] number of impressions for this location
  delegate :id, :slug, :listings, :lowest_price, :name, :description, :phone, :street, :city, :suburb, :company, :address, :latitude, :longitude, :creator, :administrator, :updated_at, :postcode, :country, :state, :lowest_full_price, :to_key, :model_name, :impressions_count, to: :location

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
    path
  end

  # @return [String] path to the first listing in the location
  def path
    @location.listings.first.try(:decorate).try(:show_path)
  end



  # @return [String] url to the first listing in the location
  # @todo -- remove
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
  # @todo -- depracate in favor of DIY url
  def google_map_url
    "http://maps.google.com/?daddr=#{@location.address}"
  end

  # @return [String] nearby eateries for this location from Yelp
  # @todo -- depracate in favor of DIY url
  def nearby_eateries_url
    "http://www.yelp.com/search?find_desc=eateries&find_loc=#{@location.address}&ns=1"
  end

  # @return [String] url to the weather information for this location at Weather Underground
  # @todo -- depracate in favor of DIY url
  def weather_url
    "http://www.wunderground.com/cgi-bin/findweather/getForecast?bannertypeclick=htmlSticker&query=#{@location.address}&GO=GO"
  end

  # @return [String] HTML-formatted address for this location
  # @todo -- lets put this into the address formatter filter or something
  def formatted_address
    location_format_address(location.address)
  end

  # @return [Boolean] whether the address has multiple parts
  # @todo -- :) Dont we have any other (more robust) way of parsing the address?
  def display_parts_of_address?
    address.split(',').length > 1
  end

  # @return [String] the first part of the address
  # @todo -- lets put this into the address formatter filter or something
  def address_formatted
    address.split(',')[0]
  end

  # @return [String] the additional parts of the address (after the first part)
  # @todo -- lets put this into the address formatter filter or something
  def address_formatted_additional
    parts = address.split(',')
    additional_parts = parts[1, parts.length]

    if additional_parts.present?
      ", #{additional_parts.join(', ')}"
    else
      ""
    end
  end

  # @return [String] route url to this location on Google Maps
  def google_maps_route
    google_maps_route_url(to: location.address, from: '')
  end

  # @return [Boolean] whether the location has special notes added to it
  # @todo -- deprecate -- DIY
  def special_notes?
    !@location.special_notes.to_s.strip.empty?
  end

  # @return [String] the special notes for this location
  def special_notes
    @location.special_notes.to_s.strip
  end

  # @return [Boolean] whether the location has a phone number added
  # @todo -- deprecate -- DIY
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
  # @todo -- since we are in location drop, rename => type_name? Or maybe type?
  def location_type_name
    @location.location_type.try(:name)
  end
end
