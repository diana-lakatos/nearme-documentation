# frozen_string_literal: true
class Payment::Gateway::Response::Stripe::BalanceTransaction
  delegate :id, :data, to: :@response

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

  def charges
    data.select { |t| t.type == 'charge' }
  end

  def payments
    data.select { |t| t.type == 'payment' }
  end

  def charges_and_payments
    charges + payments
  end
end
