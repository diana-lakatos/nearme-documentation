class PaymentVoidJob < Job
  def after_initialize(payment_id)
    @payment_id = payment_id
  end

  def perform
    @payment = Payment.with_deleted.find_by_id(@payment_id)
    @reservation = @payment.payable
    return if !(@reservation.expired? || @reservation.rejected? || @reservation.cancelled_by_guest?)
    if @payment.authorized? && @payment.active_merchant_payment?
      @payment.void!
    end
  end
end

