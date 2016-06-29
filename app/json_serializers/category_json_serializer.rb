class CategoryJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :name
  attribute :parent_name do
    object.parent.name
  end

end
