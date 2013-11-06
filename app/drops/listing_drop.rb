class ListingDrop < BaseDrop

  include AvailabilityRulesHelper
  include SearchHelper
  include MoneyRails::ActionViewExtension

  def initialize(listing)
    @listing = listing
  end

  def name
    @listing.name
  end

  def location
    @listing.location
  end

  def description
    @listing.description
  end

  def availability
    pretty_availability_sentence(@listing.availability).to_s
  end

  def dashboard_url
    routes.dashboard_url
  end

  def manage_guests_dashboard_url
    routes.manage_guests_dashboard_url(:token => @listing.creator.authentication_token)
  end

  def search_url
    routes.search_url
  end

  def search_url_with_tracking
    routes.search_url(track_email_event: true)
  end

  def bookings_dashboard_url
    routes.bookings_dashboard_url
  end

  def bookings_dashboard_url_with_tracking
    routes.bookings_dashboard_url(track_email_event: true)
  end

  def bookings_dashboard_url_with_token
    routes.bookings_dashboard_url(token: @listing.creator.authentication_token)
  end

  def bookings_dashboard_url_with_tracking_and_token
    routes.bookings_dashboard_url(token: @listing.creator.authentication_token, track_email_event: true)
  end

  def hourly_reservations?
    @listing.hourly_reservations?
  end

  def creator
    @listing.creator
  end

  def listing_url
    routes.location_listing_url(@listing.location, @listing)
  end

  def street
    @listing.location.street
  end

  def administrator
    @listing.administrator
  end

  def photo_url
    @listing.photos.any? ? @listing.photos.first.image_url(:space_listing) : image_url(Placeholder.new(:width => 410, :height => 254).path).to_s
  end

  def from_money_period
    price_information(@listing)
  end

  def manage_listing_url_with_tracking
    routes.edit_manage_location_listing_url(@listing.location, @listing, track_email_event: true, token: @listing.creator.authentication_token)
  end

  def last_booked_days
    @listing.last_booked_days
  end
end
