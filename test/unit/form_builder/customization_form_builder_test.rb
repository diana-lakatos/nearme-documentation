# frozen_string_literal: true
require 'test_helper'

class CustomizationBuilderTest < ActiveSupport::TestCase
  setup do
    CustomAttributes::CustomAttribute.destroy_all
    @transactable_type_boat = FactoryGirl.create(:transactable_type_subscription, name: 'Boat')
    @model_type = FactoryGirl.create(:custom_model_type, name: 'Boat Reviews', transactable_types: [@transactable_type_boat])
    FactoryGirl.create(:custom_attribute, name: 'author', target: @model_type)

    @customization_form = form(configuration)
  end

  should 'validate not uniq values with scope' do
    customization = @model_type.customizations.create!(customizable_id: 1, customizable_type: 'User')
    customization.update_attribute(:properties, author: 'James Joyce')

    refute @customization_form.validate(parameters)
    assert_equal ['Customizable Author already assigned to boat'], @customization_form.errors.full_messages
  end

  should 'not allow not existing attributes as scope' do
    invalid_form = form(
      customizable_id: {
        validation: { unique: { scope: [:destroy] } }
      })
    assert_raise UniqueValidator::UnknownAttributeForForm do
      invalid_form.validate(parameters)
    end
  end

  should 'validate uniq values with scope' do
    assert @customization_form.validate(parameters)
    assert_equal [], @customization_form.errors.full_messages
  end


  def parameters
    {
      customizable_id: 1,
      customizable_type: 'User',
      properties: {
        'author' => 'James Joyce'
      },
      user_id: 1
    }
  end

  def configuration
    {
      user_id: {},
      customizable_id: {
        validation: {
          unique: {
            scope: [:customizable_type, properties: :author],
            message: 'Author already assigned to boat'
          }
        }
      },
      customizable_type: {
        validation: {}
      },
      properties: {
        author: {
          validation: {}
        }
      }
    }
  end

  def form(config)
    FormBuilder.new(
      base_form: CustomizationForm,
      configuration: config,
      object: @model_type.customizations.new
    ).build
  end
end
