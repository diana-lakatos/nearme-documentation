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

  def response=(response_object)
    # When adding second CC to the same Merchant as a response
    # we expect MultiResponse object
    if response_object.class == ActiveMerchant::Billing::MultiResponse
      @credit_card.response = response_object.responses.select { |r| r.params["customer_vault_id"].present? }.first.to_yaml
    else
      @credit_card.response = response_object.to_yaml
      @credit_card.instance_client.response ||= response_object.to_yaml
    end
  end
end

