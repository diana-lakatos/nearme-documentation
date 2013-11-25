require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsApi::ItemTest < ActiveSupport::TestCase

  setup do
    AnalyticWrapper::GoogleAnalyticsApi::Item.any_instance.stubs(:version).returns(10)
    AnalyticWrapper::GoogleAnalyticsApi::Item.any_instance.stubs(:tracking_code).returns('abc-tracking')
    @google_analytic_item = AnalyticWrapper::GoogleAnalyticsApi::Item.new({
        amount: 10.28,
        reservation_charge_id: 1,
        instance_name: 'Instance name',
        listing_name: 'Listing name',
      })
  end

  should 'use correct parameters for query' do
    @google_analytic_item.user_google_analytics_id = 'some-id'
    expected_params = { v: 10, tid: 'abc-tracking', cid: 'some-id', t: "item", ti: 1, in: 'Listing name', iq: 1, iv: 'Instance name', ip: 10.28, cu: 'USD' } 
    assert_equal expected_params, @google_analytic_item.params
  end

end
