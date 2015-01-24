class CreditCard::BraintreeDecorator

  attr_accessor :credit_card

  def initialize(credit_card)
    @credit_card = credit_card
  end

  # Braintree accepts customer_vault_id as second parameter token is irrelevat
  def token
    @token ||=  response.params["customer_vault_id"]
  rescue
    nil
  end

  def response
    @response ||= YAML.load(credit_card.response)
  end
end

