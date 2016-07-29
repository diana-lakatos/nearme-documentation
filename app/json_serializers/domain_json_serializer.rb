class DomainJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :name
end
