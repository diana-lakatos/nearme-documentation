# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class InstanceProfileTypesCreator < ObjectTypesCreator
      private

      def object_class_name
        'InstanceProfileType'
      end

      def whitelisted_properties
        [:name, :profile_type]
      end
    end
  end
end
