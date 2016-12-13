# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class CategoriesCreator < DataCreator
      def execute!
        transactable_types = get_data

        transactable_types.keys.each do |tt_name|
          logger.info "Updating categories for: #{tt_name}"
          object = @instance.transactable_types.where(name: tt_name).first
          return logger.error "#{tt_name} transactable type associated with categories does not exist, create it first" unless object.present?
          update_categories_for_object(object, transactable_types[tt_name])
        end
      end

      def cleanup!
        transactable_types = get_data
        used_category_names = transactable_types.map { |_tt_name, categories| categories.map { |c| c['name'] } }.flatten.uniq
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
        File.join('categories', 'transactable_types.yml')
      end

      def update_categories_for_object(tt, categories)
        categories.each do |hash|
          hash = default_category_properties.merge(hash.symbolize_keys)
          children = hash.delete(:children) || []
          category = Category.where(name: hash[:name]).first_or_create!
          category.transactable_types = category.transactable_types.push(tt) unless category.transactable_types.include?(tt)
          category.save!

          logger.debug "Creating category #{hash[:name]}"

          create_category_tree(category, children, 1)
        end
      end

      def create_category_tree(category, children, level)
        children.each do |child|
          name = child.is_a?(Hash) ? child['name'] : child
          subcategory = category.children.where(name: name).first_or_create!(parent_id: category.id)
          logger.debug "Creating subcategory: #{name}"
          create_category_tree(subcategory, child['children'], level + 1) if child['children']
        end
      end

      def default_category_properties
        {
          mandatory: false,
          multiple_root_categories: false,
          search_options: 'include',
          children: []
        }
      end
    end
  end
end
