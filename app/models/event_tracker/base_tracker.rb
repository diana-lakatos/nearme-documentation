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
#   tracker = EventTracker::BaseTracker.new(mixpanel_analytics_backend)
#   tracker.signed_up(user)
#   tracker.cancelled_reservation(reservation)
#   tracker.accepted_reservation(reservation),
#   tracker.reviewed_booking(listing)
#   tracker.edited_listing(listing, :attributes_changed => ["price"])
#
# In order to test the execution of events in unit or functional tests, we simply need
# to mock out the relevant tracker instance and assert an expectation to call the
# relevant event method(s).
class EventTracker::BaseTracker


  def initialize(mixpanel_api, google_analytics_api)
    @mixpanel_api = mixpanel_api
    @google_analytics_api = google_analytics_api
    @invoked_events_tracker = InvokedEventsTracker.new
  end

  # it's used to add tags to sessioncam [ or whatever we end up using to track what our users do ]
  def triggered_client_taggable_methods
    @invoked_events_tracker.events
  end

  include EventTracker::CompanyEvents
  include EventTracker::ListingEvents
  include EventTracker::LocationEvents
  include EventTracker::MailerEvents
  include EventTracker::RecurringBookingEvents
  include EventTracker::ReservationEvents
  include EventTracker::SpaceWizardEvents
  include EventTracker::UserEvents

  def pixel_track_url(event_name, properties)
    @mixpanel_api.pixel_track_url(event_name, properties)
  end

  def track_charge(*objects)
    serialized_objects_hash = Serializers::TrackChargeSerializer.new(*objects).serialize
    @mixpanel_api.track_charge(serialized_objects_hash[:guest_fee])
    @mixpanel_api.track_charge(serialized_objects_hash[:host_fee], serialized_objects_hash[:host_id])
    @google_analytics_api.track_charge(serialized_objects_hash)
  end

  def apply_user(*args)
    @mixpanel_api.apply_user(*args)
    @google_analytics_api.apply_user(*args)
  end

  private

  def track(event_name, *objects)
    additional_params = Serializers::TrackSerializer.new(*objects).serialize
    @mixpanel_api.track(event_name, additional_params)
    stack_trace_parser = StackTraceParser.new(caller[0])
    @google_analytics_api.track(stack_trace_parser.humanized_file_name, event_name, additional_params)
    triggered_event = stack_trace_parser.humanized_method_name
    @invoked_events_tracker.push(triggered_event)
  end

  # Sets global properties on the person
  def set_person_properties(*objects)
    @mixpanel_api.set_person_properties Serializers::TrackSerializer.new(*objects).serialize
  end

end

