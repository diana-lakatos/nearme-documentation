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
        [:name, :instance_profile_types]
      end

      def parse_params(hash)
        hash = hash.with_indifferent_access
        hash[:instance_profile_types] = hash[:instance_profile_types].map { |ipt_name| InstanceProfileType.find_by(instance_id: @instance.id, name: ipt_name) } if hash[:instance_profile_types]
        hash
      end

      def find_or_create!(hash)
        CustomModelType.where(instance_id: @instance.id, name: hash[:name]).first_or_create!
      end
    end
  end
end
