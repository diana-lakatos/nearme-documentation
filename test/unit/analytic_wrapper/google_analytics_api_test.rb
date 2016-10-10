require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsApiTest < ActiveSupport::TestCase
  context 'tracking methods' do
    setup do
      @endpoint = 'http//example.com'
      @version = 1
      @tracking_code = 'tracking-code'
      AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:tracking_code).returns(@tracking_code)
      AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:endpoint).returns(@endpoint)
      AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:version).returns(@version)
      @google_analytics = AnalyticWrapper::GoogleAnalyticsApi.new(nil)
      @google_analytics.stubs(:default_params).returns(default_param: 'value')
    end

    context 'track' do
      setup do
        @event = stub(serialize: { returned: 'value' })
        AnalyticWrapper::GoogleAnalyticsSerializer::Event.expects(:new).returns(@event)
      end

      should 'track Event for track method' do
        GoogleAnalyticsApiJob.expects(:perform).with(@endpoint, default_param: 'value', returned: 'value')
        @google_analytics.track
      end
    end

    context 'track_charge' do
      setup do
        @item = stub(serialize: { returned: 'item_value' })
        @transaction = stub(serialize: { returned: 'transaction_value' })
        AnalyticWrapper::GoogleAnalyticsSerializer::Item.expects(:new).returns(@item)
        AnalyticWrapper::GoogleAnalyticsSerializer::Transaction.expects(:new).returns(@transaction)
      end

      should 'track Transaction and Item for track_charge method' do
        GoogleAnalyticsApiJob.expects(:perform).with(@endpoint, default_param: 'value', returned: 'item_value')
        GoogleAnalyticsApiJob.expects(:perform).with(@endpoint, default_param: 'value', returned: 'transaction_value')
        @google_analytics.track_charge
      end
    end
  end

  context 'default_params' do
    setup do
      @endpoint = 'http//example.com'
      @version = 1
      @tracking_code = 'tracking-code'
      AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:tracking_code).returns(@tracking_code)
      AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:endpoint).returns(@endpoint)
      AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:version).returns(@version)
    end

    should 'return correct params for not logged in user' do
      @google_analytics = AnalyticWrapper::GoogleAnalyticsApi.new(nil)
      assert_equal({ v: @version, tid: @tracking_code, cid: '555', an: 'DesksNearMe' }, @google_analytics.send(:default_params))
    end

    should 'return correct params for logged in user' do
      @google_analytics = AnalyticWrapper::GoogleAnalyticsApi.new(FactoryGirl.create(:user, google_analytics_id: '123'))
      assert_equal({ v: @version, tid: @tracking_code, cid: '123', an: 'DesksNearMe' }, @google_analytics.send(:default_params))
    end
  end
end
