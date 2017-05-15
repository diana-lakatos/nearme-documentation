class PaymentRefundJob < Job
  def after_initialize(payment_id, amount)
    @payment_id = payment_id
    @amount = amount
  end

  def perform
    Payment.find(@payment_id).refund!(@amount)
  rescue ActiveRecord::RecordNotFound
    false
  end
end
