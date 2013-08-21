class LocationDrop < Liquid::Drop
  include ReservationsHelper
  include SharingHelper

  def initialize(location)
    @location = location
  end

  def name
    @location.name
  end

  def url
    Rails.application.routes.url_helpers.location_url(@location)
  end

  def tweet_url
    tweet_location_url(@location)
  end

  def special_notes?
    !@location.special_notes.strip.to_s.empty?
  end

  def special_notes
    @location.special_notes.strip
  end

  def phone?
    @location.phone.present?
  end

  def phone
    @location.phone
  end
end
