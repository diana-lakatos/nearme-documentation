# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class CategoriesCreator < DataCreator
      def execute!
        categories = get_data
        return if categories.empty?

        MarketplaceBuilder::Logger.info('Creating categories')

        remove_unused_categories(categories)
        categories.keys.each do |tt_name|
          MarketplaceBuilder::Logger.log "\t#{tt_name}:"
          object = @instance.transactable_types.where(name: tt_name).first
          unless object.present?
            return MarketplaceBuilder::Logger.error "#{tt_name} transactable type associated with categories does not exist, create it first"
          end
          update_categories_for_object(object, categories[tt_name])
        end
      end

      private

      def source
        File.join('categories', 'transactable_types.yml')
      end

      def remove_unused_categories(categories)
        used_categories = []

        categories.each do |_tt, cats|
          cats.each { |c| used_categories << c['name'] }
        end

        used_categories.uniq!

        unused_categories = Category.where('name NOT IN (?) AND parent_id IS NULL', used_categories)
        unless unused_categories.empty?
          MarketplaceBuilder::Logger.log "\tRemoving unused categories:"
          unused_categories.each do |category|
            MarketplaceBuilder::Logger.log "\t  - #{category.name}"
            category.destroy!
          end
        end
      end

      def update_categories_for_object(tt, categories)
        MarketplaceBuilder::Logger.log "\t  Updating / creating categories:"

        categories.each do |hash|
          hash = default_category_properties.merge(hash.symbolize_keys)
          children = hash.delete(:children) || []
          category = Category.where(name: hash[:name]).first_or_create!
          category.transactable_types = category.transactable_types.push(tt) unless category.transactable_types.include?(tt)
          category.save!

          MarketplaceBuilder::Logger.log "\t    - #{hash[:name]}"

          create_category_tree(category, children, 1)
        end
      end

      def create_category_tree(category, children, level)
        children.each do |child|
          name = child.is_a?(Hash) ? child['name'] : child
          subcategory = category.children.where(name: name).first_or_create!(parent_id: category.id)
          MarketplaceBuilder::Logger.log "\t    #{'  ' * (level + 1)}- #{name}"
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
