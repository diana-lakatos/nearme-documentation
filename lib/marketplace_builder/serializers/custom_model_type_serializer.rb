# frozen_string_literal: true
module MarketplaceBuilder
  module Serializers
    class CustomModelTypeSerializer < BaseSerializer
      resource_name ->(c) { "custom_model_types/#{c.name.parameterize('_')}" }

      properties :name
      property :instance_profile_types
      property :transactable_types

      serialize :custom_attributes, using: CustomAttributeSerializer

      def instance_profile_types(custom_model_type)
        custom_model_type.instance_profile_types.map(&:name)
      end

      def transactable_types(custom_model_type)
        custom_model_type.transactable_types.map(&:name)
      end

      def scope
        CustomModelType.where(instance_id: @model.id).all
      end
    end
  end
end
