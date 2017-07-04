# frozen_string_literal: true
require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportCategory < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        cat = Category.create!(instance_id: @instance.id,
                               name: 'Extras',
                               multiple_root_categories: true,
                               shared_with_users: true,
                               mandatory: true,
                               search_options: 'exclude',
                               display_options: 'tree')

        cat.instance_profile_types << (@instance.default_profile_type || FactoryGirl.create(:instance_profile_type))
        cat.transactable_types << (@instance.transactable_types.create! name: 'Car')
        cat.save!

        cat_1 = cat.children.create!(name: 'Cat 1')
        cat_1.children.create!(name: 'Cat 1.1')

        cat_1_2 = cat_1.children.create!(name: 'Cat 1.2')
        cat_1_2.children.create!(name: 'Cat 1.2.1')
        cat_1_2.children.create!(name: 'Cat 1.2.2')

        cat.children.create!(name: 'Child Seat')
        cat.children.create!(name: 'Bike Rack')
      end

      def execute!
        yaml_content = read_exported_file('categories/extras.yml')
        assert_equal yaml_content['name'], 'Extras'
        assert_equal yaml_content['multiple_root_categories'], true
        assert_equal yaml_content['shared_with_users'], true
        assert_equal yaml_content['mandatory'], true
        assert_equal yaml_content['search_options'], 'exclude'
        assert_equal yaml_content['display_options'], 'tree'
        assert_same_elements yaml_content['transactable_types'], ['Car']
        assert_same_elements yaml_content['instance_profile_types'], ['Default']
        assert_same_elements yaml_content['children'], [
          {
            'name' =>  'Cat 1',
            'children' => [
              {
                'name' => 'Cat 1.1',
                'children' => []
              },
              {
                'name' => 'Cat 1.2',
                'children' => [
                  {
                    'name' => 'Cat 1.2.1',
                    'children' => []
                  },
                  {
                    'name' => 'Cat 1.2.2',
                    'children' => []
                  }
                ]
              }
            ]
          },
          {
            'name' => 'Child Seat',
            'children' => []
          },
          {
            'name' => 'Bike Rack',
            'children' => []
          }
        ]
      end
    end
  end
end
