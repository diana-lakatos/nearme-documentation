# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class ShouldImportCategories < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        category = Category.roots.last
        assert_equal category.name, 'Extras'
        assert_equal category.multiple_root_categories, true
        assert_equal category.shared_with_users, true
        assert_equal category.display_options, 'tree'
        assert_equal category.search_options, 'exclude'

        assert_equal category.children.count, 3
        assert_equal category.children.first.name, 'Cat 1'
        assert_equal category.children.first.children.first.name, 'Cat 1.1'
        assert_equal category.children.first.children.last.name, 'Cat 1.2'
        assert_equal category.children.first.children.count, 2
        assert_equal category.children.first.children.last.children.count, 2
        assert_equal category.children.first.children.last.children.first.name, 'Cat 1.2.1'
        assert_equal category.children.first.children.last.children.last.name, 'Cat 1.2.2'

        assert_equal category.transactable_types.first.name, 'Car'
        assert_equal category.instance_profile_types.first.name, 'Default'
      end
    end
  end
end
