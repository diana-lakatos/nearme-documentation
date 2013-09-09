class ListingDrop < BaseDrop
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
    routes.dashboard_url
  end

  def manage_guests_dashboard_url
    routes.manage_guests_dashboard_url(:token => @listing.creator.authentication_token)
  end

  def search_url
    routes.search_url
  end

  def bookings_dashboard_url
    routes.bookings_dashboard_url
  end

  def hourly_reservations?
    @listing.hourly_reservations?
  end

  def creator
    @listing.creator
  end
end
