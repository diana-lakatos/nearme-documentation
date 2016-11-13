# frozen_string_literal: true
class PaymentGateway::Response::Braintree::Refund
  delegate :id, :amount, to: :@response

  def initialize(response)
    @response = response
  end

  def amount
    @response.amount.to_money
  end

  delegate :cents, to: :amount, prefix: true

  def success?
    %w(submitted_for_settlement settled).include? @response.status
  end
end
