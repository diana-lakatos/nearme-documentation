# frozen_string_literal: true
require 'test_helper'

class Graph::SchemaTest < ActiveSupport::TestCase
  setup do
    @context = {}
    @variables = {}
  end

  context 'user query' do
    setup { @user = FactoryGirl.create(:user) }
    should 'get user' do
      query = %({ users { name } })

      assert_equal @user.name, result(query)['data']['users'].first['name']
    end

    should 'get user custom attribute' do
      add_custom_attribute('hair_color', 'red', @user)

      query = %({ users { hair_color: custom_attribute(name: "hair_color") } })

      assert_equal @user.properties.hair_color, result(query)['data']['users'].first['hair_color']
    end
  end

  def result(query)
    Graph::Schema.execute(
      query,
      context: @context,
      variables: @variables
    )
  end

  def add_custom_attribute(name, value, user)
    FactoryGirl.create(
      :custom_attribute,
      name: name, target: InstanceProfileType.default.first, attribute_type: 'string'
    )
    user.reload.properties.hair_color = value
    user.save!
  end
end
