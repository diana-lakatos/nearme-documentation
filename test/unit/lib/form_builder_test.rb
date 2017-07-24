# frozen_string_literal: true
require 'test_helper_lite'
require 'mocha/setup'
require 'mocha/mini_test'

class FormBuilderTest < ActiveSupport::TestCase
  should 'do not re-create class for known config:' do
    UserForm.expects(:decorate).with(configuration_with_mandatory_field).returns(mock_object).once
    FormBuilder.new(configuration: configuration_with_mandatory_field, base_form: UserForm, object: mock).build
    FormBuilder.new(configuration: configuration_with_mandatory_field, base_form: UserForm, object: mock).build
  end

  should 'do not confuse form classes' do
    UserForm.expects(:decorate).with(configuration_with_optional_field).returns(mock_object).once
    TransactableForm.expects(:decorate).with(configuration_with_optional_field).returns(mock_object).once
    FormBuilder.new(configuration: configuration_with_optional_field, base_form: UserForm, object: mock).build
    FormBuilder.new(configuration: configuration_with_optional_field, base_form: TransactableForm, object: mock).build
    FormBuilder.new(configuration: configuration_with_optional_field, base_form: TransactableForm, object: mock).build
  end

  should 'do not confuse different configurations' do
    UserForm.expects(:decorate).with(last_name: {}).returns(mock_object).once
    UserForm.expects(:decorate).with(first_name: {}).returns(mock_object).once
    FormBuilder.new(configuration: { last_name: {} }, base_form: UserForm, object: mock).build
    FormBuilder.new(configuration: { first_name: {} }, base_form: UserForm, object: mock).build
  end

  protected

  def mock_object
    stub(new: mock)
  end

  def configuration_with_mandatory_field
    {
      name: {
        validation: true
      }
    }
  end

  def configuration_with_optional_field
    {
      name: {
        validation: {}
      }
    }
  end
end
