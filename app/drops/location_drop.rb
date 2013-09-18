class LocationDrop < BaseDrop
  include ReservationsHelper
  include SharingHelper

  def initialize(location)
    @location = location
  end

  def name
    @location.name
  end

  def url
    routes.location_listing_url(@location, @location.listings.first)
  end

  def tweet_url
    tweet_location_url(routes.location_url(@location))
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
end
