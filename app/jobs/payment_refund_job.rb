class PaymentRefundJob < Job
  def after_initialize(payment_id)
    @payment_id = payment_id
  end

  def perform
    Payment.find(@payment_id).refund!
  rescue ActiveRecord::RecordNotFound
    false
  end
end
