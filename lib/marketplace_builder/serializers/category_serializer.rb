module MarketplaceBuilder
  module Serializers
    class CategorySerializer < BaseSerializer
      resource_name -> (t) { "categories/#{t.name.underscore}" }

      properties :name, :multiple_root_categories, :shared_with_users

      property :transactable_types
      property :instance_profile_types

      serialize :children, using: CategorySerializer

      def transactable_types(category)
        category.transactable_types.map(&:name)
      end

      def instance_profile_types(category)
        category.instance_profile_types.map(&:name)
      end

      def scope
        @model.kind_of?(Instance) ? Category.where(instance_id: @model.id, parent_id: nil): @model.children
      end
    end
  end
end
