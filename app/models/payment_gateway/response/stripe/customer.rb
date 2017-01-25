# frozen_string_literal: true
class PaymentGateway::Response::Stripe::Customer
  attr_reader :response
  delegate :id, :sources, to: :@response

  def initialize(response)
    @response = response
    raise "Parse error" unless @response.object == 'customer'
  end

  def marked_for_destruction?
    false
  end

  def bank_accounts
    @response.sources.data.select { |b| b.object == 'bank_account'}.map do |bank_account_response|
      PaymentGateway::Response::Stripe::BankAccount.new(bank_account_response)
    end
  end
end
