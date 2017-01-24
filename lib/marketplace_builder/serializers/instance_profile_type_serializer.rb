module MarketplaceBuilder
  module Serializers
    class InstanceProfileTypeSerializer < BaseSerializer
      resource_name -> (t) { "instance_profile_types/#{t.name.underscore}" }

      properties :name, :profile_type

      serialize :validation, using: CustomValidationSerializer
      serialize :custom_attributes, using: CustomAttributeSerializer

      def scope
        @model.instance_profile_types
      end
    end
  end
end
