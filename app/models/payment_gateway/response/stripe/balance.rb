# frozen_string_literal: true
class PaymentGateway::Response::Stripe::Balance
  delegate :id, to: :@response

  def amount_cents
    @response.amount
  end

  def initialize(response)
    @response = response
  end

  def success?
    @response.status == 'succeeded'
  end

  def payment_gateway_fee_cents
    @response.fee_details.select { |fee| fee.type == 'stripe_fee' }.sum(&:amount)
  end
end
