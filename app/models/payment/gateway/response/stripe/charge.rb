# frozen_string_literal: true
class Payment::Gateway::Response::Stripe::Charge
  delegate :id, :source_transfer, to: :@response

  def initialize(response)
    @response = response
  end

  def amount_cents
    @response.amount
  end

  def state
    refunded? ? 'refunded' : paid? ? 'paid' : 'authorized'
  end

  def paid?
    @response.paid
  end

  def refunded?
    @response.refunded || refunds.any?
  end

  def mode
    @response.livemode ? PaymentGateway::LIVE_MODE : PaymentGateway::TEST_MODE
  end

  def refunds
    return [] if @response.refunds.data.blank?

    @response.refunds.map do |refund_response|
      Payment::Gateway::Response::Stripe::Refund.new(refund_response)
    end
  end

  def success?
    @response.status == 'succeeded'
  end
end
