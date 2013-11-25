require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsApi::TransactionTest < ActiveSupport::TestCase

  setup do
    AnalyticWrapper::GoogleAnalyticsApi::Transaction.any_instance.stubs(:version).returns(10)
    AnalyticWrapper::GoogleAnalyticsApi::Transaction.any_instance.stubs(:tracking_code).returns('abc-tracking')
    @google_analytic_transaction = AnalyticWrapper::GoogleAnalyticsApi::Transaction.new({
        amount: 10.28,
        reservation_charge_id: 1,
        instance_name: 'Instance name',
        listing_name: 'Listing name',
      })
  end

  should 'use correct parameters for query' do
    @google_analytic_transaction.user_google_analytics_id = 'some-id'
    expected_params = { v: 10, tid: 'abc-tracking', cid: 'some-id', t: "transaction", ti: 1, ta: 'Instance name', tr: 10.28, cu: 'USD' }
    assert_equal expected_params, @google_analytic_transaction.params
  end

end
