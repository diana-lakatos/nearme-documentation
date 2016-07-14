class V3::TransactableJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :slug
  attribute :name
  attribute :description
  attribute :latitude
  attribute :longitude
  attribute :company_name
  attribute :currency
  attribute :address
  attribute :postcode
  attribute :street
  attribute :suburb
  attribute :state
  attribute :city
  attribute :country
  attribute :quantity
  attribute :location_name do
    object.location.name
  end
  attribute :photos_metadata
  attribute :properties do
    object.properties.to_liquid
  end

  has_one :location, include_links: false
  has_one :company, include_links: false
  has_one :creator, include_links: false
  has_one :action_type, include_links: false
  has_many :categories, include_links: false
end
