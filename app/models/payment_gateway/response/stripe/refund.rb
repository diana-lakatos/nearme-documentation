class PaymentGateway::Response::Stripe::Refund
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
end
