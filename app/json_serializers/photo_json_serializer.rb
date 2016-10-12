class PhotoJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :space_listing_url do
    object.image_url(:space_listing)
  end
  attribute :medium_url do
    object.image_url(:medium)
  end
end
