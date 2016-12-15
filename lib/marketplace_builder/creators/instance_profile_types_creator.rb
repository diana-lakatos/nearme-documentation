# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class InstanceProfileTypesCreator < ObjectTypesCreator
      private

      def object_class_name
        'InstanceProfileType'
      end

      def whitelisted_properties
        [:name, :profile_type, :onboarding, :searchable, :search_only_enabled_profiles]
      end

      def find_or_create!(hash)
        InstanceProfileType.where(instance_id: @instance.id, profile_type: hash[:profile_type]).first_or_create!
      rescue
      end
    end
  end
end
