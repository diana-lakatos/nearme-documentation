class UserJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :slug
end
