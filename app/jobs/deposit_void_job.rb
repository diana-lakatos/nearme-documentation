class DepositVoidJob < Job
  def after_initialize(payment_id)
    @payment_id = payment_id
  end

  def perform
    @payment = Payment.with_deleted.find_by(id: @payment_id)
    @deposit = @payment.payable
    @reservation = @deposit.target
    return unless @reservation.archived?
    if @payment.authorized? && @payment.active_merchant_payment?
      @payment.void!
      @deposit.update!(voided_at: Time.now)
    end
  end
end
