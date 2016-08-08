class PaymentGateway::Response::Braintree::Payment
  attr_reader :refunds

  RESPONSE_STATES = {
    pending: %w(authorizing).freeze,
    authorized: %w(authorized settlement_pending settlement_confirmed settling submitted_for_settlement).freeze,
    voided: %w(voided).freeze,
    paid: %w(settled).freeze,
    failed: %w(authorization_expired settlement_declined failed gateway_rejected processor_declined).freeze
  }.freeze

  RESPONSE_STATES.each do |state_name, states_array|
    define_method "#{state_name}?" do
      states_array.include?(@response.status)
    end
  end

  delegate :id, :refund_ids, to: :@response

  def initialize(response, refunds = [])
    @response = response
    @refunds = refunds
  end

  def amount
    @response.amount.to_money
  end

  delegate :cents, to: :amount, prefix: true

  def state
    RESPONSE_STATES.select { |_k, v| v.include?(@response.status) }.keys[0]
  end

  def refunded?
    @response.refund_ids.present?
  end

  def mode
    @response.livemode ? PaymentGateway::LIVE_MODE : PaymentGateway::TEST_MODE
  end

  def add_refund(refund)
    @refunds << refund
  end
end
