# frozen_string_literal: true
class PaymentReloaderService
  def initialize(payment)
    @payment = payment
  end

  def process!
    return if (payment_response = @payment.fetch).blank?

    @payemnt.mark_as_failed! if @payment.authorized? && payment_response.failed?
    @payemnt.mark_as_voided! if @payment.authorized? && payment_response.void?
    @payemnt.mark_as_paid! if @payment.authorized? && payment_response.paid?
    @payment.mark_as_refuneded! if @payment.paid? && payment_response.refunded?

    process_refunds(payment_response.refunds) if @payment.refunded?

    true
  end

  private

  def process_refunds(refund_responses)
    refund_responses.each { |refund_response| create_refund(refund_response) }
  end

  def create_refund(refund_response)
    return if @payment.refunds.where(external_id: refund_response.id).any?

    @payment.refunds.where(amount_cents: refund_response.amount_cents).first_or_create!(
      receiver: 'guest',
      amount_cents: refund_response.amount_cents,
      currency: @payment.currency,
      payment_gateway_mode: @payment.payment_gateway_mode,
      payment_gateway: @payment.payment_gateway,
      success: refund_response.success?,
      response: refund_response.to_yaml
    ).update_attribute(:external_id, refund_response.id)
  end
end
