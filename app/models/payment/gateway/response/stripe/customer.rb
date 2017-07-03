# frozen_string_literal: true
class Payment::Gateway::Response::Stripe::Customer
  attr_reader :response
  delegate :sources, :name, :email, to: :@response

  # The problem with this parser is that we use Active Merchant to store Customer
  # on CreditCard create and we Store Stripe Customer object when BankAccount create
  # TODO we should probably migrate to Stripe Gem responses as ActiveMerchant is not enough anymore
  def id
    response.respond_to?(:authorization) ? (response.authorization || params['id']): response.try(:id)
  end

  alias token id
  alias customer_id id

  def initialize(response)
    @response = response
  end

  def params
    response.respond_to?(:params) ? response.params : {}
  end

  def active?
    true
  end

  def bank_accounts
    @response.sources.data.select { |b| b.object == 'bank_account'}.map do |bank_account_response|
      Payment::Gateway::Response::Stripe::BankAccount.new(bank_account_response)
    end
  end
end
