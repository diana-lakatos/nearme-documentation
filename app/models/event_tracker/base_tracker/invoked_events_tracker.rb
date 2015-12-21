# Stores all events that were invoked by user.
# Used by third party software tagging system - current one is sessioncam
class EventTracker::BaseTracker::InvokedEventsTracker

  TAGGABLE_EVENTS = ['Requested a booking', 'Created a location', 'Created a listing', 'Saved a draft', 'Signed up', 'Logged in' ]

  attr_accessor :events

  def initialize
    @events = []
  end

  def push(event_name)
    @events << event_name if should_be_tracked?(event_name)
  end

  private

  def should_be_tracked?(event_name)
    !@events.include?(event_name) && TAGGABLE_EVENTS.include?(event_name)
  end
end

