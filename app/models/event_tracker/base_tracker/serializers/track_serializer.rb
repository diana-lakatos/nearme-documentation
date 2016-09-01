# Extracts necessary attributes from objects passed to track_charge

class EventTracker::BaseTracker::Serializers::TrackSerializer

  def initialize(*objects)
    @objects = objects
  end

  def serialize
    @objects.compact.map { |o| serialize_object(o) }.inject(:merge) || {}
  end

  private

  def serialize_object(object)
    self.class.serialize_object(object)
  end

  def self.serialize_object(object)
    case object
    when Location
      {
        location_address: object.address,
        location_suburb: object.suburb,
        location_city: object.city,
        location_state: object.state,
        location_country: object.country,
        location_postcode: object.postcode,
        location_url: object.listings.first.try(:decorate).try(:show_url)
      }
    when Transactable
      {
        listing_name: safe_get(object, 'name'),
        listing_quantity: safe_get(object, 'quantity'),
        listing_confirm: safe_get(object, 'confirm_reservations'),
        listing_pricings: get_prices(object),
        listing_currency: safe_get(object, 'currency'),
        listing_url: object.try(:decorate).try(:show_url)
      }
    when RecurringBooking
      {
        booking_ndesks: object.quantity,
        location_address: object.location.address,
        location_suburb: object.location.suburb,
        location_city: object.location.city,
        location_state: object.location.state,
        location_country: object.location.country,
        location_postcode: object.location.postcode
      }
    when Reservation
      {
        booking_desks: object.quantity,
        booking_days: object.total_days,
        booking_total: object.total_amount.try(:dollars),
        booking_currency: object.currency,
        location_address: object.location.address,
        location_suburb: object.location.suburb,
        location_city: object.location.city,
        location_state: object.location.state,
        location_country: object.location.country,
        location_postcode: object.location.postcode
      }
    when Purchase
      {
        booking_desks: object.quantity,
        booking_total: object.total_amount.try(:dollars),
        booking_currency: object.currency,
      }
    when Offer
      {
        booking_desks: object.quantity,
        booking_total: object.total_amount.try(:dollars),
        booking_currency: object.currency,
      }
    when User
      {
        first_name: object.first_name,
        last_name: object.last_name,
        email: object.email,
        phone: object.phone,
        created: object.created_at,
        location_number: object.locations.count,
        listing_number: object.listings.count,
        bookings_total: object.orders.reservations.count,
        bookings_confirmed: object.confirmed_reservations.count,
        bookings_rejected: object.rejected_reservations.count,
        bookings_expired: object.expired_reservations.count,
        bookings_cancelled: object.cancelled_reservations.count,
        google_analytics_id: object.google_analytics_id,
        browser: object.browser,
        browser_version: object.browser_version,
        platform: object.platform
      }
    when Listing::Search::Params::Web
      {
        search_street: object.street,
        search_suburb: object.suburb,
        search_city: object.city,
        search_state: object.state,
        search_country: object.country,
        search_postcode: object.postcode
      }
    when Company
      {
        company_name: object.name,
        company_email: object.email,
        company_url: object.url,
        company_paypal_email: object.paypal_email
      }
    when Hash
      object
    else
      raise "Can't serialize #{object}."
    end
  end

  def self.get_prices(listing)
    listing.action_type.pricings.map{|p| p.price_information.merge({ price: p.price.to_f })}
  end

  def self.safe_get(object, property)
    object.respond_to?(property) ? object.send(property) : nil
  end

end

