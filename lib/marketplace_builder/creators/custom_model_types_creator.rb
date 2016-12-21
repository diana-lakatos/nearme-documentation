# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class CustomModelTypesCreator < ObjectTypesCreator
      def base_scope
        CustomModelType.where(instance_id: @instance.id)
      end

      private

      def object_class_name
        'CustomModelType'
      end

      def whitelisted_properties
        [:name, :instance_profile_types, :transactable_types]
      end

      def find_or_create!(hash)
        CustomModelType.where(instance_id: @instance.id, name: hash[:name]).first_or_create!
      end
    end
  end
end
