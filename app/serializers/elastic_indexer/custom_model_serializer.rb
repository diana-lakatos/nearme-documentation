module ElasticIndexer
  class CustomModelSerializer < BaseSerializer
    attributes :name,
               :properties


    def properties
      CustomModelPropertySerializer.new(object.properties, scope: object.custom_model_type).as_json
    end

    def name
      object.custom_model_type.name
    end
  end
end
