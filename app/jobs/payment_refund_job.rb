class PaymentRefundJob < Job
  def after_initialize(payment_id, counter)
    @payment_id = payment_id
    @counter = counter
  end

  def perform
    @payment = Payment.find_by_id(@payment_id)
    if @payment
      @payment.attempt_payment_refund(@counter)
    else
      false
    end
  end
end

