class CreditCard::StripeDecorator

  attr_accessor :credit_card

  def initialize(credit_card)
    @credit_card = credit_card
  end

  def token
    @token ||= response.params["object"] == 'card' ? response.params["id"] : response.params["default_source"]
  end

  def response
    @response ||= YAML.load(credit_card.response)
  end

  def response=(response_object)
    # When adding second CC to the same Merchant as a response
    # we expect MultiResponse object
    if response_object.class == ActiveMerchant::Billing::MultiResponse
      credit_card.response = response_object.responses.select { |r| r.params['object'] == 'card' }.first.to_yaml
      customer_response = response_object.responses.select { |r| r.params['object'] == 'customer'}.first
      if customer_response.params['id'] != credit_card.instance_client.customer_id
        credit_card.instance_client.response = customer_response.to_yaml
      end
    else
      credit_card.response = response_object.to_yaml
      credit_card.instance_client.response ||= response_object.to_yaml
    end
  end
end

