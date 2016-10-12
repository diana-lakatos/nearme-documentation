require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsSerializer::EventTest < ActiveSupport::TestCase
  setup do
    @google_analytic_event = AnalyticWrapper::GoogleAnalyticsSerializer::Event.new('category', 'action')
  end

  should 'use correct parameters for query' do
    expected_params = { t: 'event', ec: 'category', ea: 'action' }
    assert_equal expected_params, @google_analytic_event.serialize
  end
end
