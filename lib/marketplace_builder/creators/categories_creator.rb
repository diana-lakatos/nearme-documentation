# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class CategoriesCreator < DataCreator
      def execute!
        categories = get_data

        categories.each do |_key, hash|
          hash = default_category_properties.merge(hash.symbolize_keys)
          logger.info "Updating category: #{hash[:name]}"

          transactable_types = hash.delete(:transactable_types).each_with_object([]) do |name, arr|
            tt = @instance.transactable_types.where(name: name).first
            return logger.error "'#{name}' is not a valid transactable type name for category '#{hash[:name]}'" unless tt

            logger.debug "Adding '#{name}' transactable type to category '#{hash[:name]}'"
            arr << tt
          end

          instance_profile_types = hash.delete(:instance_profile_types).each_with_object([]) do |name, arr|
            ipt = @instance.instance_profile_types.where(name: name).first
            return logger.error "#{name} is not a valid instance profile type name for category #{hash[:name]}" unless ipt

            logger.debug "Adding #{name} instance profile type to category #{hash[:name]}"
            arr << ipt
          end

          children = hash.delete(:children)

          category = Category.where(name: hash[:name]).first_or_create!
          category.assign_attributes(hash)
          category.transactable_types = transactable_types
          category.instance_profile_types = instance_profile_types
          category.save!

          create_category_tree(category, children, 1)
        end
      end

      def cleanup!
        categories = get_data
        used_category_names = categories.map { |_key, category| category['name'] }
        unused_categories = if used_category_names.empty?
                              Category.all
                            else
                              Category.where('name NOT IN (?) AND parent_id IS NULL', used_category_names)
                            end

        unused_categories.each { |category| logger.debug "Removing unused category #{category.name}" }
        unused_categories.destroy_all
      end

      private

      def source
        File.join('categories')
      end

      def create_category_tree(category, children, level)
        children_names = []
        children.each do |child|
          name = child.is_a?(Hash) ? child['name'] : child
          children_names << name
          subcategory = category.children.where(name: name).first_or_create!(parent_id: category.id)
          logger.debug "Creating subcategory: #{name}"
          create_category_tree(subcategory, child['children'], level + 1) if child['children']
        end
        category.children.where.not(name: children_names).destroy_all
      end

      def default_category_properties
        {
          mandatory: false,
          multiple_root_categories: false,
          search_options: 'include',
          transactable_types: [],
          instance_profile_types: [],
          children: []
        }
      end
    end
  end
end
