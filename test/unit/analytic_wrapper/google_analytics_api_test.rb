require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsApiTest < ActiveSupport::TestCase

  setup do
    @google_analytics = AnalyticWrapper::GoogleAnalyticsApi.new(nil)
  end

  should 'track Event for track method' do
    @event = stub()
    AnalyticWrapper::GoogleAnalyticsApi::Event.expects(:new).with("string1", "string2").returns(@event)
    @event.expects(:user_google_analytics_id=)
    @event.expects(:track)
    @google_analytics.track("string1", "string2")
  end

  should 'track Transaction and Item for track_charge method' do
    @transaction = stub()
    @item = stub()
    AnalyticWrapper::GoogleAnalyticsApi::Transaction.expects(:new).with({:hash => 'value'}).returns(@transaction)
    AnalyticWrapper::GoogleAnalyticsApi::Item.expects(:new).with({:hash => 'value'}).returns(@item)
    @transaction.expects(:user_google_analytics_id=)
    @transaction.expects(:track)
    @item.expects(:user_google_analytics_id=)
    @item.expects(:track)
    @google_analytics.track_charge({:hash => 'value'})
  end

end
