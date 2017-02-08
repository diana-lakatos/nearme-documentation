module ElasticIndexer
  class UserBlogSerializer < BaseSerializer
    attributes :name,
               :enabled

    has_one :header_logo, serializer: ImageUploaderSerializer
    has_one :header_icon, serializer: ImageUploaderSerializer
    has_one :header_image, serializer: ImageUploaderSerializer
  end
end
