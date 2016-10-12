require 'test_helper'

class EventTracker::BaseTracker::InvokedEventsTrackerTest < ActiveSupport::TestCase
  context '#event tracker' do
    should 'should be able to trigger each taggable event' do
      EventTracker::BaseTracker::InvokedEventsTracker::TAGGABLE_EVENTS.each do |taggable_event|
        assert Rails.application.config.event_tracker.method_defined?(taggable_event.parameterize('_').underscore), "Taggable event #{taggable_event} will never be triggered, because EventTracker has no #{taggable_event.parameterize('_').underscore} method"
      end
    end

    setup do
      @invoked_events_tracker = EventTracker::BaseTracker::InvokedEventsTracker.new
    end

    should 'know which events are taggable' do
      @invoked_events_tracker.push('Requested a booking')
      @invoked_events_tracker.push('Created a location')
      assert_equal ['Requested a booking', 'Created a location'], @invoked_events_tracker.events
    end

    should 'know which events are not taggable' do
      @invoked_events_tracker.push('Conducted a search')
      assert_equal [], @invoked_events_tracker.events
    end
  end
end
