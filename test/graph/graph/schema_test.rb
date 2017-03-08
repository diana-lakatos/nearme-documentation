# frozen_string_literal: true
require 'test_helper'
require 'graph/schema'

class Graph::SchemaTest < ActiveSupport::TestCase
  setup do
    @context = {}
    @variables = {}
  end

  context 'user query' do
    setup do
      @user = FactoryGirl.create(:user)
    end

    should 'get user' do
      query = %({ users { name } })

      assert_equal @user.name, result(query)['users'].first['name']
    end

    should 'get user custom attribute' do
      add_custom_attribute('hair_color', 'red', @user)

      query = %({ users { hair_color: custom_attribute(name: "hair_color") } })

      assert_equal @user.properties.hair_color, result(query)['users'].first['hair_color']
    end

    should 'get user pending collaborations' do
      collaborator = FactoryGirl.create(:transactable_collaborator, user: @user, transactable: FactoryGirl.create(:transactable, user: @user))
      User.where.not(id: @user.id).delete_all

      query = %({ users { collaborations(filters: [PENDING_RECEIVED_INVITATION]) { id } }})

      assert_equal({"users" => [{"collaborations" => [{ "id"=>"1" }] }]}, result(query))
    end
  end

  def result(query)
    Graph.execute_query(
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
