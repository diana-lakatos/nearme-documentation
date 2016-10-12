class CreditCard::BraintreeDecorator
  attr_accessor :credit_card

  def initialize(credit_card)
    @credit_card = credit_card
  end

  # Braintree accepts customer_vault_id as second parameter token is irrelevat
  def token
    @token ||= primary_response.params['customer_vault_id']
  rescue
    nil
  end

  # priamry_response is work around for ActiveMerchant MultiResponse that
  # is send back when second CreditCard is subscribed to existing Customer.

  def primary_response
    response.respond_to?(:primary_response) ? response.primary_response : response
  end

  def expires_at
    card.expiration_date.try(:to_datetime)
  end

  def last_4
    card.last_4
  end

  def name
    [response.params['braintree_customer']['first_name'], response.params['braintree_customer']['last_name']].join(' ') rescue 'Unknown'
  end

  def card
    OpenStruct.new(response.params['braintree_customer']['credit_cards'].first) rescue OpenStruct.new(last_4: '????', expiration_date: nil)
  end

  def response
    @response ||= YAML.load(credit_card.response)
  end
end
