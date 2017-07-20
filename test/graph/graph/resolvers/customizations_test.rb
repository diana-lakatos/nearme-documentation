# frozen_string_literal: true
require 'test_helper'
require 'graph/schema'

class Graph::Resolvers::CustomizationsTest < ActiveSupport::TestCase
  context 'customizations resolver' do
    setup do
      @customization = FactoryGirl.create(:customization)
      @customization2 = FactoryGirl.create(:customization,
                                          custom_model_type: @customization.custom_model_type,
                                          customizable: @customization.customizable,
                                          user: @customization.user)
    end

    should 'get customizations' do
      args = {
        name: @customization.custom_model_type.parameterized_name
      }
      customizations = Graph::Resolvers::Customizations.new.call(nil, args, nil)

      assert_not_empty customizations
      assert_equal 2, customizations.size
    end

    should 'get customization' do
      args = {
        name: @customization.custom_model_type.parameterized_name,
        id: @customization2.id
      }
      customization = Graph::Resolvers::Customization.new.call(nil, args, nil)

      assert_not_nil customization
    end

    should 'return empty array' do
      args = {
        name: @customization.custom_model_type.parameterized_name,
        id: 0
      }
      customization = Graph::Resolvers::Customization.new.call(nil, args, nil)

      assert_nil customization
    end

    should 'return parent objects only' do
      @customization3 = FactoryGirl.create(:customization,
                                           user: @customization.user,
                                           custom_model_type: @customization.custom_model_type)
      args = {
        name: @customization.custom_model_type.parameterized_name
      }
      customizations = Graph::Resolvers::Customizations.new.call(@customization.customizable, args, nil)

      assert_equal 2, customizations.size
      assert_includes customizations, @customization2
      refute_includes customizations, @customization3
    end
  end
end
