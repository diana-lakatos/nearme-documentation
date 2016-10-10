require 'test_helper'

class AnalyticWrapper::GoogleAnalyticsSerializer::TransactionTest < ActiveSupport::TestCase
  setup do
    @google_analytic_transaction = AnalyticWrapper::GoogleAnalyticsSerializer::Transaction.new(amount: 10.28,
                                                                                               payment_id: 1,
                                                                                               instance_name: 'Instance name',
                                                                                               listing_name: 'Listing name')
  end

  should 'seralize correctly' do
    expected_params = { t: 'transaction', ti: 1, ta: 'Instance name', tr: 10.28, cu: 'USD' }
    assert_equal expected_params, @google_analytic_transaction.serialize
  end
end
