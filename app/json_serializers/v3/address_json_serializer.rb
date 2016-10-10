class V3::AddressJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :address
  attribute :address2
  attribute :street
  attribute :suburb
  attribute :city
  attribute :country
  attribute :state
  attribute :postcode
  attribute :latitude
  attribute :longitude
end
