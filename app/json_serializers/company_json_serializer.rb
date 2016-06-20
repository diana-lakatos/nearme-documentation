class CompanyJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :name

  has_many :locations, include_links: false
  has_many :listings, include_links: false
  has_one :creator, include_links: false
end
