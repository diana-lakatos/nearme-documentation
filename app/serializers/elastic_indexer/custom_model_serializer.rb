module ElasticIndexer
  class CustomModelSerializer < BaseSerializer
    attributes :name,
               :properties
    has_many :custom_images, serializer: CustomImageSerializer
    has_many :custom_attachments, serializer: CustomAttachmentSerializer

    def properties
      CustomModelPropertySerializer.new(object.properties, scope: object.custom_model_type).as_json
    end

    def name
      object.custom_model_type.name
    end
  end
end
