module ElasticIndexer
  class CustomImageSerializer < BaseSerializer
    attributes :public,
               :name,
               :label

    has_one :image, key: :versions, serializer: ImageUploaderSerializer

    delegate :custom_attribute, to: :object
    delegate :public, :name, :label, to: :custom_attribute
  end
end
