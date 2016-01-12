require 'test_helper'
require 'marketplace_error_logger'

class PaymentRefundJobTest < ActiveSupport::TestCase

  should 'run the right method' do
    payment = FactoryGirl.create(:paid_payment)
    Payment.any_instance.expects(:refund!).returns(false).at_least(3)
    MarketplaceErrorLogger::DummyLogger.any_instance.expects(:log_issue).once
    PaymentRefundJob.perform(payment.id, 0)
  end

  should 'refund correctly' do
    stub_active_merchant_interaction
    payment = FactoryGirl.create(:paid_payment)
    PaymentRefundJob.perform(payment.id, 0)
    assert payment.reload.refunded?
  end
end
