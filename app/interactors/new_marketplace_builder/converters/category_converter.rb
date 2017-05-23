# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class CategoryConverter < BaseConverter
      primary_key :name
      properties :name, :multiple_root_categories, :shared_with_users, :mandatory, :search_options, :display_options
      property :instance_profile_types
      property :transactable_types
      property :children

      def scope
        Category.roots.where(instance_id: @model.id).all
      end

      def instance_profile_types(category)
        category.instance_profile_types.map(&:name)
      end

      def set_instance_profile_types(category, value)
        category.instance_profile_types = Array(value).map { |name| InstanceProfileType.find_by!(instance_id: @model.id, name: name) }
      end

      def transactable_types(category)
        category.transactable_types.map(&:name)
      end

      def set_transactable_types(category, value)
        category.transactable_types = Array(value).map { |name| TransactableType.find_by!(instance_id: @model.id, name: name) }
      end

      def children(category)
        category.children.map { |child_category| children_to_hash(child_category) }
      end

      def set_children(category, value = [])
        create_category_tree(category, value, 1)
      end

      protected

      def children_to_hash(category)
        {
          name: category.name,
          children: category.children.map { |child_category| children_to_hash(child_category) },
          position: category.position
        }
      end

      def create_category_tree(category, children, level)
        children ||= []
        children_names = []

        children.each do |child|
          name = child.is_a?(Hash) ? child['name'] : child
          children_names << name
          subcategory = category.children.where(name: name).first
          unless subcategory
            subcategory = Category.new(name: name, parent: category, position: child['position'])
            category.children << subcategory
          end
          create_category_tree(subcategory, child['children'], level + 1) if child['children']
        end
        category.children.where.not(name: children_names).destroy_all
      end
    end
  end
end
