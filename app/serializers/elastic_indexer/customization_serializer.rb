module ElasticIndexer
  class CustomizationSerializer < BaseSerializer
    attributes :id, :user_id, :created_at, :properties, :name, :human_name

    has_many :custom_images, serializer: CustomImageSerializer
    has_many :custom_attachments, serializer: CustomAttachmentSerializer

    def properties
      CustomModelPropertySerializer.new(object.properties, scope: object.custom_model_type).as_json
    end

    def human_name
      object.custom_model_type.name
    end

    def name
      object.custom_model_type.parameterized_name
    end
  end
end
