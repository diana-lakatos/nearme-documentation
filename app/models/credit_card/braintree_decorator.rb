class CreditCard::BraintreeDecorator

  attr_accessor :credit_card

  def initialize(credit_card)
    @credit_card = credit_card
  end

  # Braintree accepts customer_vault_id as second parameter token is irrelevat
  def token
    @token ||= primary_response.params["customer_vault_id"]
  rescue
    nil
  end

  # priamry_response is work around for ActiveMerchant MultiResponse that
  # is send back when second CreditCard is subscribed to existing Customer.

  def primary_response
    response.respond_to?(:primary_response) ? response.primary_response : response
  end

  def response
    @response ||= YAML.load(credit_card.response)
  end
end

