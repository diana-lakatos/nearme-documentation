class V3::ActionTypeJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :type
  attribute :no_action
  attribute :action_rfq
  attribute :available_prices_in_cents

  has_many :pricings, include_links: false
end
