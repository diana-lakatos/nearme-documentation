class Analytics::EventTracker
  attr_accessor :user

  def initialize(api, user)
    @api = api
    self.user = user
  end

  def user=(user)
    @user = user

    if @user
      set(@user.id, @user)
    end
  end

  include ListingEvents
  include LocationEvents
  include ReservationEvents
  include SpaceWizardEvents
  include UserEvents

  def charge(user_id, total_amount_dollars)
    @api.track_charge(user_id, total_amount_dollars)
  end

  private

  def set(user_id, *objects)
    @api.set(user_id, event_properties(objects))
  end

  def track_event(event_name, *objects)
    @api.track(event_name, serialize_event_properties(objects))
  end

  def serialize_event_properties(objects)
    begin
      event_properties(objects).merge!(global_event_properties)
    rescue
      {}
    end
  end

  def event_properties(objects)
    objects.map { |o| serialize_object(o)
    }.inject(:merge)
  end

  def global_event_properties
    hash = {}

    unless @user.nil?
      hash.merge!({ distinct_id: @user.id })
    end

    hash
  end

  def serialize_object(object)
    case object
    when Location
      {
        location_address: object.address,
        location_currency: object.currency,
        location_suburb: object.suburb,
        location_city: object.city,
        location_state: object.state,
        location_country: object.country
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
        booking_total: object.total_amount_dollars
      }
    when User
      {
        name: object.name,
        email: object.email,
        phone: object.phone,
        job_title: object.job_title
      }
    when Listing::Search::Params::Web
      {
        search_suburb: object.suburb,
        search_city: object.city,
        search_state: object.state,
        search_country: object.country
      }
    when Hash
      object
    else
      raise "Can't serialize #{object}."
    end
  end

end

