require 'test_helper'

class AnalyticWrapper::ClientEventsTest < ActiveSupport::TestCase

  context '#event tracker' do
    should "should be able to trigger each taggable event" do
      AnalyticWrapper::ClientEvents::TAGGABLE_EVENTS.each do |taggable_event|
        assert Analytics::EventTracker.method_defined?(taggable_event.parameterize('_').underscore), "Taggable event #{taggable_event} will never be triggered, because EventTracker has no #{taggable_event.parameterize('_').underscore} method"
      end
    end

    should 'know which events are taggable' do
      assert AnalyticWrapper::ClientEvents.taggable?("Requested a booking")
      assert AnalyticWrapper::ClientEvents.taggable?("Created a location")
    end

    should 'know which events are not taggable' do
      assert !AnalyticWrapper::ClientEvents.taggable?("Conducted a search")
    end
  end
end
