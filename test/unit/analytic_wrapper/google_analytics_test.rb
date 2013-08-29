require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsApiTest < ActiveSupport::TestCase

  setup do
    AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:version).returns(10)
    AnalyticWrapper::GoogleAnalyticsApi.any_instance.stubs(:tracking_code).returns('abc-tracking')
    @google_analytic = AnalyticWrapper::GoogleAnalyticsApi.new(nil)
  end

  should 'use default customer id if current_user is nil' do
    expected_params = { v: 10, tid: 'abc-tracking', cid: '555', t: "event", ec: 'category', ea: 'action'} 
    assert_equal expected_params, @google_analytic.get_params('category', 'action')
  end

  should 'use current_user google_analytics_id if not nil' do
    @google_analytic = AnalyticWrapper::GoogleAnalyticsApi.new(FactoryGirl.create(:user, :google_analytics_id => 'some-id'))
    expected_params = { v: 10, tid: 'abc-tracking', cid: 'some-id', t: "event", ec: 'category', ea: 'action'} 
    assert_equal expected_params, @google_analytic.get_params('category', 'action')
  end

end
