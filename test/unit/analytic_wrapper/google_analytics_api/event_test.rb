require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsApi::EventTest < ActiveSupport::TestCase

  setup do
    AnalyticWrapper::GoogleAnalyticsApi::Event::any_instance.stubs(:version).returns(10)
    AnalyticWrapper::GoogleAnalyticsApi::Event.any_instance.stubs(:tracking_code).returns('abc-tracking')
    @google_analytic_event = AnalyticWrapper::GoogleAnalyticsApi::Event.new('category', 'action')
  end

  should 'use correct parameters for query' do
    @google_analytic_event.user_google_analytics_id = 'some-id'
    expected_params = { v: 10, tid: 'abc-tracking', cid: 'some-id', t: "event", ec: 'category', ea: 'action'} 
    assert_equal expected_params, @google_analytic_event.params
  end

end
