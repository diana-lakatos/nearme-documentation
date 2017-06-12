require 'test_helper'
require 'marketplace_error_logger'

class PaymentRefundJobTest < ActiveSupport::TestCase
  should 'run the right method' do
    payment = FactoryGirl.create(:paid_payment)
    PaymentGateway.any_instance.expects(:gateway_refund).returns(OpenStruct.new(success?: false)).times(3)
    MarketplaceErrorLogger::ActiveRecordLogger.any_instance.expects(:log_issue).once
    payment.refund!(payment.total_amount_cents)
  end

  should 'refund correctly' do
    stub_active_merchant_interaction
    payment = FactoryGirl.create(:paid_payment)
    PaymentRefundJob.perform(payment.id, payment.total_amount_cents)
    assert payment.reload.refunded?
  end
end
