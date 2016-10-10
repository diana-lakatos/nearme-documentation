require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsSerializer::ItemTest < ActiveSupport::TestCase
  setup do
    @google_analytic_item = AnalyticWrapper::GoogleAnalyticsSerializer::Item.new(amount: 10.28,
                                                                                 payment_id: 1,
                                                                                 instance_name: 'Instance name',
                                                                                 listing_name: 'Listing name')
  end

  should 'use correct parameters for query' do
    expected_params = { t: 'item', ti: 1, in: 'Listing name', iq: 1, iv: 'Instance name', ip: 10.28, cu: 'USD' }
    assert_equal expected_params, @google_analytic_item.serialize
  end
end
