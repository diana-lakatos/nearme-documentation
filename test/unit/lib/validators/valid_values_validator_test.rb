require 'test_helper'

class ValidValuesValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    attr_accessor :name, :quantity, :boolean_value
  end

  setup do
    @dummy_class = ValidValuesValidatorTest::DummyClass.new
  end

  should 'not pass validation if attribute is not valid' do
    @dummy_class.name = 'd'
    ValidValuesValidator.new(record: @dummy_class,
                             field_name: :name,
                             valid_values: %w(a b c))
                        .validate
    assert_equal 'Name is not included in the list', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if attribute is valid' do
    @dummy_class.name = 'a'
    ValidValuesValidator.new(record: @dummy_class,
                             field_name: :name,
                             valid_values: %w(a b c))
                        .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end

  should 'not be case sensitive' do
    @dummy_class.name = 'A'
    ValidValuesValidator.new(record: @dummy_class,
                             field_name: :name,
                             valid_values: %w(a b c))
                        .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if empty string' do
    @dummy_class.name = ''
    ValidValuesValidator.new(record: @dummy_class,
                             field_name: :name,
                             valid_values: %w(a b c))
                        .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if valid values is empty' do
    @dummy_class.name = 'a'
    ValidValuesValidator.new(record: @dummy_class,
                             field_name: :name,
                             valid_values: %w())
                        .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if valid values is nil' do
    @dummy_class.name = 'a'
    ValidValuesValidator.new(record: @dummy_class,
                             field_name: :name,
                             valid_values: nil)
                        .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end
end
