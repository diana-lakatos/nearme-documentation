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
  attribute :quantity
  attribute :state

  attribute :location_address do
    object.location_address.attributes.slice('address', 'postcode', 'street', 'suburb', 'state', 'city', 'country', 'address_components')
  end

  attribute :pricings do
    object.action_type.pricings.each_with_object({}) do |pricing, hash|
      hash[pricing.unit] = pricing.price.to_s
    end
  end

  attribute :path do
    object.decorate.show_path
  end
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
