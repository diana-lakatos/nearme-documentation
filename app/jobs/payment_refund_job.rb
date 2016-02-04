class PaymentRefundJob < Job
  def after_initialize(payment_id)
    @payment_id = payment_id
  end

  def perform
    @payment = Payment.find_by_id(@payment_id)
    if @payment
      @payment.refund!
    else
      false
    end
  end
end

