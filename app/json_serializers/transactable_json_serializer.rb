class TransactableJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :slug
  attribute :name

  has_one :location, include_links: false
  has_one :company, include_links: false
  has_one :creator, include_links: false
end
