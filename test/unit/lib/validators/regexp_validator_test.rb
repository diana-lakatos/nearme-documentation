require 'test_helper'

class RegexpValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    attr_accessor :name, :quantity, :boolean_value
  end

  setup do
    @dummy_class = RegexpValidatorTest::DummyClass.new
  end

  should 'not pass validation if attribute does not match regexp' do
    @dummy_class.name = 'hello I am Maciek'
    RegexpValidator.new(record: @dummy_class,
                        field_name: :name,
                        regexp: '(.+)I AM(.+)')
                   .validate
    assert_equal 'Name has an invalid format', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if attribute matches regexp' do
    @dummy_class.name = 'hello I AM Maciek'
    RegexpValidator.new(record: @dummy_class,
                        field_name: :name,
                        regexp: '(.+)I AM(.+)')
                   .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if attribute is empty string' do
    @dummy_class.name = ''
    RegexpValidator.new(record: @dummy_class,
                        field_name: :name,
                        regexp: '(.+)I AM(.+)')
                   .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if regexp is nil' do
    @dummy_class.name = 'something'
    RegexpValidator.new(record: @dummy_class,
                        field_name: :name,
                        regexp: nil)
                   .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end

  should 'pass validation if regexp is blank' do
    @dummy_class.name = 'something'
    RegexpValidator.new(record: @dummy_class,
                        field_name: :name,
                        regexp: '')
                   .validate
    assert_equal '', @dummy_class.errors.full_messages.join(', ')
  end
end
