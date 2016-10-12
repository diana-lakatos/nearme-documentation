class PaymentVoidJob < Job
  def after_initialize(payment_id)
    @payment_id = payment_id
  end

  def perform
    @payment = Payment.with_deleted.find_by(id: @payment_id)
    @reservation = @payment.payable
    return unless @reservation.expired? || @reservation.rejected? || @reservation.cancelled_by_guest?
    @payment.void! if @payment.authorized? && @payment.active_merchant_payment?
  end
end
