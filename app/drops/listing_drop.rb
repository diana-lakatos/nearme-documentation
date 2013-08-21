class ListingDrop < Liquid::Drop
  def initialize(listing)
    @listing = listing
  end

  def name
    @listing.name
  end

  def location
    @listing.location
  end

  def dashboard_url
    Rails.application.routes.url_helpers.dashboard_url
  end

  def manage_guests_dashboard_url
    Rails.application.routes.url_helpers.manage_guests_dashboard_url(:token => @listing.creator.authentication_token)
  end

  def search_url
    Rails.application.routes.url_helpers.search_url
  end

  def bookings_dashboard_url
    Rails.application.routes.url_helpers.bookings_dashboard_url
  end

  def hourly_reservations?
    @listing.hourly_reservations?
  end

  def creator
    @listing.creator
  end
end
