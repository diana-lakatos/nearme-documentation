# frozen_string_literal: true
require 'test_helper'
require 'graph/schema'

class Graph::CustomizationMutationsTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @customization = add_custom_model(model_name: 'Cars', attr_name: 'model_attr', object: @user.default_profile)
  end

  should 'update customization' do
    query = %(mutation {
      customization_update(id: #{@customization.id}, customization: { title: "foo" }, form_configuration: "#{form_configuration.name}"){
        id
      }
    })

    result = Graph.execute_query(query, context: { 'current_user' => @user })

    assert_equal(@customization.id.to_s, result.dig('customization_update', 'id'))
  end

  should 'delete customization' do
    query = %(mutation {
      customization_delete(id: #{@customization.id}, form_configuration: "#{form_configuration.name}"){
        id
      }
    })

    result = Graph.execute_query(query, context: { 'current_user' => @user })

    assert_equal(@customization.id.to_s, result.dig('customization_delete', 'id'))
  end

  def add_custom_model(model_name:, attr_name:, object:)
    default_profile_type = PlatformContext.current.instance.default_profile_type
    model = FactoryGirl.create(:custom_model_type, name: model_name, instance_profile_types: [default_profile_type])
    FactoryGirl.create(:custom_attribute, name: attr_name, target: model)
    customization = Customization.new(custom_model_type: model, properties: { attr_name => 'mazda' })
    object.customizations << customization
    customization
  end

  def form_configuration
    @form_configuration ||= FactoryGirl.create(
      :form_configuration,
      name: 'customization_form',
      base_form: 'CustomizationForm',
      configuration: {
        properties: {
          model_attr: {
            validation: {
              presence: true
            }
          }
        }
      }
    )
  end
end
