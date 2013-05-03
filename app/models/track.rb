class Track 

  def self.analytics
    @analytics ||= Analytics.new
  end

  def self.location_hash(location)
    {
      location_address: location.address,
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

  def self.user_hash(user)
    {
      name: user.name,
      email: user.email,
      phone: user.phone,
      job_title: user.job_title
    }
  end

  def self.distinct_id(current_user_id)
    hash = {}

    unless current_user_id.nil?
      hash.merge!({ distinct_id: current_user_id })
    end

    hash
  end

  class List
    def self.created_a_location(current_user_id, via, location)
      Track.analytics.track('Created a Location', [
        {
          via: via
        },
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.created_a_listing(current_user_id, via, listing)
      Track.analytics.track('Created a Listing', [
        {
          via: via
        },
        Track.listing_hash(listing),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.viewed_list_your_space_sign_up(current_user_id)
      Track.analytics.track('Viewed List Your Space, Sign Up', Track.distinct_id(current_user_id))
    end

    def self.viewed_list_your_space_list(current_user_id)
      Track.analytics.track('Viewed List Your Space, List', Track.distinct_id(current_user_id))
    end

  end

  class Book
    def self.opened_booking_modal(current_user_id, user_signed_in, reservation, location)
      Track.analytics.track('Opened the Booking Modal', [
        {
          logged_in: user_signed_in
        },
        Track.reservation_hash(reservation),
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.requested_a_booking(current_user_id, reservation, location)
      Track.analytics.track('Requested a Booking', [
        Track.reservation_hash(reservation),
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.confirmed_a_booking(current_user_id, reservation, location)
      Track.analytics.track('Confirmed a Booking', [
        Track.reservation_hash(reservation),
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.rejected_a_booking(current_user_id, reservation, location)
      Track.analytics.track('Rejected a Booking', [
        Track.reservation_hash(reservation),
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.cancelled_a_booking(current_user_id, actor, reservation, location)
      Track.analytics.track('Cancelled a Booking', [
        {
          actor: actor
        },
        Track.reservation_hash(reservation),
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.booking_expired(current_user_id, reservation, location)
      Track.analytics.track('Booking Expired', [
        Track.reservation_hash(reservation),
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

  end

  class User
    def self.signed_up(user, referrer, omniauth)
      # We should .alias the user here so we keep events relating to their anonymous browsing.
      # When this is merged: https://github.com/zevarito/mixpanel/pull/92

      Track.analytics.set(user.id, Track.user_hash(user))

      Track.analytics.track('Signed Up', [
        {
          via: Track::User.via(referrer),
          provider: Track::User.provider(omniauth)
        },
        Track.distinct_id(user.id)
      ].inject(:merge))
    end

    def self.logged_in(user, referrer, omniauth)
      Track.analytics.track('Logged In', [
        {
          via: Track::User.via(referrer),
          provider: Track::User.provider(omniauth)
        },
        Track.distinct_id(user.id)
      ].inject(:merge))

      Track.analytics.set(user.id, Track.user_hash(user))
    end

    def self.charge(current_user_id, total_amount_dollars)
      Track.analytics.track_charge(current_user_id, total_amount_dollars)
    end

    def self.via(referrer)
      if !referrer.nil? && referrer.include?('return_to=%2Fspace%2Flist&wizard=space')
        'flow'
      else
        'other'
      end
    end

    def self.provider(omniauth)
      provider = unless omniauth.nil?
        omniauth[:provider]
      else
        'native'
      end
    end
  end

  class Search

    def self.conducted_a_search(current_user_id, view, search, number_of_results)
      ac = Track::Search.address_components(search, number_of_results)

      Track.analytics.track('Conducted a Search', [
        {
          search_view: view,
          search_suburb: ac.fetch('suburb', nil),
          search_city: ac.fetch('city', nil),
          search_state: ac.fetch('state', nil),
          search_country: ac.fetch('country', nil),
          search_result_count: number_of_results
        },
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.viewed_a_location(current_user_id, user_signed_in, location)
      Track.analytics.track('Viewed a Location', [
        {
          logged_in: user_signed_in
        },
        Track.location_hash(location),
        Track.distinct_id(current_user_id)
      ].inject(:merge))
    end

    def self.address_components(search, number_of_results)
      if number_of_results > 0 && search.address_components.present?
        search.address_components.result_hash
      else
        {}
      end
    end
  end

end
