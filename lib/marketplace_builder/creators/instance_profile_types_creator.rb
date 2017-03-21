# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class InstanceProfileTypesCreator < ObjectTypesCreator
      private

      def object_class_name
        'InstanceProfileType'
      end

      def whitelisted_properties
        [
          :name, :profile_type, :onboarding, :searchable, :category_search_type,
          :searchable, :search_only_enabled_profiles, :search_engine,
          :default_availability_template, :create_company_on_sign_up, :admin_approval
        ]
      end

      def parse_params(hash)
        hash = hash.with_indifferent_access
        hash[:default_availability_template] = PlatformContext.current.instance.availability_templates.where(name: hash[:default_availability_template]).first if hash[:default_availability_template]
        hash
      end

      def find_or_create!(hash)
        InstanceProfileType.with_deleted.where(instance_id: @instance.id, profile_type: hash[:profile_type]).first_or_create!
      end
    end
  end
end
