class Track

  def self.analytics
    @analytics ||= Analytics.new
  end

  def self.location_hash(location)
    {
      location_currency: location.currency,
      location_suburb: location.suburb,
      location_city: location.city,
      location_state: location.state,
      location_country: location.country,
    }
  end

  def self.listing_hash(listing)
    {
      listing_name: listing.name,
      listing_quantity: listing.quantity,
      listing_confirm: listing.confirm_reservations,
      listing_daily_price: listing.daily_price.try(:dollars),
      listing_weekly_price: listing.weekly_price.try(:dollars),
      listing_monthly_price: listing.monthly_price.try(:dollars)
    }
  end

  def self.reservation_hash(reservation)
    {
      payment_method: reservation.payment_method,
      booking_desks: reservation.quantity,
      booking_days: reservation.total_days,
      booking_total: reservation.total_amount_dollars
    }
  end

  class List
    def self.created_a_location(via, location)
      Track.analytics.track('Created a Location', Track.location_hash(location).merge({
        via: via
      }))
    end

    def self.created_a_listing(via, listing)
      Track.analytics.track('Created a Listing', Track.listing_hash(listing).merge({
        via: via
      }))
    end

    def self.deleted_a_location(location)
      Track.analytics.track('Deleted a Location', Track.location_hash(location))
    end

    def self.deleted_a_listing(listing)
      Track.analytics.track('Deleted a Listing', Track.listing_hash(listing))
    end

    def self.updated_a_location(location)
      Track.analytics.track('Updated a Location', Track.location_hash(location))
    end

    def self.updated_a_listing(listing)
      Track.analytics.track('Updated a Listing', Track.listing_hash(listing))
    end

  end

  class Book
    def self.opened_booking_modal(user_signed_in, reservation, location)
      Track.analytics.track('Opened the Booking Modal', [
                              {
                                logged_in: user_signed_in
                              },
                              Track.reservation_hash(reservation),
                              Track.location_hash(location)
                            ].inject(:merge))
    end

    def self.requested_a_booking(reservation, location)
      Track.analytics.track('Requested a Booking', [
                              Track.reservation_hash(reservation),
                              Track.location_hash(location)
                            ].inject(:merge))
    end

    def self.confirmed_a_booking(reservation, location)
      Track.analytics.track('Confirmed a Booking', [
                              Track.reservation_hash(reservation),
                              Track.location_hash(location)
                            ].inject(:merge))
    end

  end

  class User

  end

  class Search

    def self.conducted_a_search(view, search)
      address_components = search.address_components.try(:result_hash)

      Track.analytics.track('Conducted a Search', {
        search_view: view,
        search_suburb: address_components.fetch('suburb'),
        search_city: address_components.fetch('city'),
        search_state: address_components.fetch('state'),
        search_country: address_components.fetch('country')
      })
    end

    def self.viewed_a_location(user_signed_in, location)
      Track.analytics.track('Viewed a Location', Track.location_hash(location).merge({
        logged_in: user_signed_in
      }))
    end

  end

end
