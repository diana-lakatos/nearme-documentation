class PaymentGateway::Response::Braintree::Refund
  delegate :id, :amount, to: :@response

  def initialize(response)
    @response = response
  end

  def amount
    @response.amount.to_money
  end

  def amount_cents
    amount.cents
  end

  def success?
    ['submitted_for_settlement', 'settled'].include? @response.status
  end
end
