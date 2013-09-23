require 'test_helper'

class AnalyticWrapper::InspectletTest < ActiveSupport::TestCase

  context '#tags' do
    should "event_tracker should be able to trigger each taggable event" do
      AnalyticWrapper::Inspectlet::TAGGABLE_EVENTS.each do |taggable_event|
        assert Analytics::EventTracker.method_defined?(taggable_event), "Taggable event #{taggable_event} will never be triggered, because EventTracker has no such method"
      end
    end

    should 'return array of humanized names' do
      assert_equal ["Requested a booking", "Created a location"], AnalyticWrapper::Inspectlet.tags(['requested_a_booking', 'created_a_location'])
    end

    should 'not accept not trackable events' do
      assert_equal ["Requested a booking"], AnalyticWrapper::Inspectlet.tags(['requested_a_booking', 'this_is_not_allowed'])
    end
  end
end
