# frozen_string_literal: true
class PaymentGateway::Response::Stripe::BankAccount
  attr_reader :response

  delegate :id, :bank_name, :status, :last4, to: :@response

  def initialize(response)
    raise 'Parse error' unless response.object == 'bank_account'
    @response = response
  end
end
