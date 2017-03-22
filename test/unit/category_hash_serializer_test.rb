# frozen_string_literal: true
require 'test_helper'

class CategoryHashSerializerTest < ActiveSupport::TestCase
  context 'should return correct structure #1' do
    setup do
      #  Tree looks like
      #  root
      #  |
      #  \______category_1
      #  |          |
      #  |          \_______category_2
      #  |                      |
      #  |                      \________category_3
      #  |                      |            \_________category_4
      #  |                      |
      #  |                      \________category_5
      #  |                                   \_________category_6
      #  |
      #  \______category_7
      #

      @category_root = FactoryGirl.create(:category)
      @category1 = FactoryGirl.create(:category, parent_id: @category_root.id)
      @category2 = FactoryGirl.create(:category, parent_id: @category1.id)
      @category3 = FactoryGirl.create(:category, parent_id: @category2.id)
      @category4 = FactoryGirl.create(:category, parent_id: @category3.id)
      @category5 = FactoryGirl.create(:category, parent_id: @category2.id)
      @category6 = FactoryGirl.create(:category, parent_id: @category5.id)
      @category7 = FactoryGirl.create(:category, parent_id: @category_root.id)

      @category_root.reload
      @category1.reload
      @category2.reload
      @category3.reload
      @category4.reload
      @category5.reload
      @category6.reload
      @category7.reload
    end

    should 'return correct tree structure' do
      assert_equal accepted_tree_structure_as_string(categories: [@category_root, @category1, @category2,
                                                                  @category3, @category4, @category5,
                                                                  @category6, @category7]),
                   JSON.pretty_generate(CategoryHashSerializer.new(@category_root, []).to_json)
    end
  end

  private

  def accepted_tree_structure_as_string(args)
    categories = args[:categories]

    structure = <<-structure
{
  "id": #{categories[0].id},
  "text": "#{categories[0].name}",
  "state": {
    "opened": false,
    "checked": false
  },
  "children": [
    {
      "id": #{categories[1].id},
      "text": "#{categories[1].name}",
      "state": {
        "opened": false,
        "checked": false
      },
      "children": [
        {
          "id": #{categories[2].id},
          "text": "#{categories[2].name}",
          "state": {
            "opened": false,
            "checked": false
          },
          "children": [
            {
              "id": #{categories[3].id},
              "text": "#{categories[3].name}",
              "state": {
                "opened": false,
                "checked": false
              },
              "children": [
                {
                  "id": #{categories[4].id},
                  "text": "#{categories[4].name}",
                  "state": {
                    "opened": false,
                    "checked": false
                  },
                  "children": [

                  ]
                }
              ]
            },
            {
              "id": #{categories[5].id},
              "text": "#{categories[5].name}",
              "state": {
                "opened": false,
                "checked": false
              },
              "children": [
                {
                  "id": #{categories[6].id},
                  "text": "#{categories[6].name}",
                  "state": {
                    "opened": false,
                    "checked": false
                  },
                  "children": [

                  ]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "id": #{categories[7].id},
      "text": "#{categories[7].name}",
      "state": {
        "opened": false,
        "checked": false
      },
      "children": [

      ]
    }
  ]
}
structure
    structure.strip
  end
end
