# Encapsulates the logic and attributes behind tracking specific
# events or actions within the application.
#
# Builds up the event property data, and executes the tracking through
# the underlying Mixpanel API object.
#
# We can later extend this to execute tracking through alternative
# analytics backends.
#
# In summary, this object simply encapsulates the logic behind translating
# actions from our domain into events & parameters in the analytics domain,
# to make triggering and testing these events trivial from within our
# application controllers.
#
# Usage:
#
#   tracker = Analytics::EventTracker.new(mixpanel_analytics_backend)
#   tracker.signed_up(user)
#   tracker.cancelled_reservation(reservation)
#   tracker.accepted_reservation(reservation)
#   tracker.reviewed_booking(listing)
#   tracker.edited_listing(listing, :attributes_changed => ["price"])
#
# In order to test the execution of events in unit or functional tests, we simply need
# to mock out the relevant tracker instance and assert an expectation to call the
# relevant event method(s).
class Analytics::EventTracker
  def initialize(api)
    @api = api
  end

  include ListingEvents
  include LocationEvents
  include ReservationEvents
  include SpaceWizardEvents
  include UserEvents

  private

  def track(event_name, *objects)
    @api.track(event_name, serialize_event_properties(objects))
  end

  def track_charge(user_id, total_amount_dollars)
    @api.track_charge(user_id, total_amount_dollars)
  end

  # Sets global properties on the person
  def set_person_properties(*objects)
    @api.set_person_properties event_properties(objects)
  end

  def serialize_event_properties(objects)
    begin
      event_properties(objects)
    rescue
      {}
    end
  end

  def event_properties(objects)
    objects.map { |o| serialize_object(o) }.inject(:merge) || {}
  end

  def serialize_object(object)
    self.class.serialize_object(object)
  end

  def self.serialize_object(object)
    case object
    when Location
      {
        location_address: object.address,
        location_currency: object.currency,
        location_suburb: object.suburb,
        location_city: object.city,
        location_state: object.state,
        location_country: object.country,
        location_postcode: object.postcode
      }
    when Listing
      {
        listing_name: object.name,
        listing_quantity: object.quantity,
        listing_confirm: object.confirm_reservations,
        listing_daily_price: object.daily_price.try(:dollars),
        listing_weekly_price: object.weekly_price.try(:dollars),
        listing_monthly_price: object.monthly_price.try(:dollars)
      }
    when Reservation
      {
        booking_desks: object.quantity,
        booking_days: object.total_days,
        booking_total: object.total_amount_dollars,
        location_address: object.location.address,
        location_currency: object.location.currency,
        location_suburb: object.location.suburb,
        location_city: object.location.city,
        location_state: object.location.state,
        location_country: object.location.country,
        location_postcode: object.location.postcode
      }
    when User
      {
        first_name: object.first_name,
        last_name: object.last_name,
        email: object.email,
        phone: object.phone,
        job_title: object.job_title,
        created: object.created_at
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
    when Hash
      object
    else
      raise "Can't serialize #{object}."
    end
  end

end

