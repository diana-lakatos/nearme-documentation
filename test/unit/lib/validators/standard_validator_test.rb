require 'test_helper'

class StandardValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model
    attr_accessor :name, :quantity, :boolean_value
  end

  setup do
    @dummy_class = StandardValidatorTest::DummyClass.new
  end

  context 'presence' do
    should 'add error if attribute is nil' do
      @dummy_class.name = nil
      StandardValidator.new(argument_hash_with_rules(validation_rules: { 'presence' => {} })).validate
      assert_equal 'Name can\'t be blank', @dummy_class.errors.full_messages.join(', ')
    end

    should 'add error if attribute is empty string' do
      @dummy_class.name = ''
      StandardValidator.new(argument_hash_with_rules(validation_rules: { 'presence' => {} })).validate
      assert_equal 'Name can\'t be blank', @dummy_class.errors.full_messages.join(', ')
    end

    should 'pass validation if attribute present' do
      @dummy_class.name = 'Maciek'
      StandardValidator.new(argument_hash_with_rules(validation_rules: { 'presence' => {} })).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end
  end

  context 'inclusion' do
    should 'pass validation if attribute is true' do
      @dummy_class.boolean_value = true
      StandardValidator.new(
        argument_hash_with_rules(
          field_name: 'boolean_value',
          validation_rules: { 'inclusion' => { 'in' => [true, false] } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end

    should 'pass validation if attribute is nil' do
      @dummy_class.boolean_value = nil
      StandardValidator.new(
        argument_hash_with_rules(
          field_name: 'boolean_value',
          validation_rules: { 'inclusion' => { 'in' => [true, false] } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end

    should 'fail if attribute outside of defined values' do
      @dummy_class.boolean_value = 'true'
      StandardValidator.new(
        argument_hash_with_rules(
          field_name: 'boolean_value', validation_rules: { 'inclusion' => { 'in' => [true, false] } }
        )
      ).validate
      assert_equal 'Boolean value is not included in the list', @dummy_class.errors.full_messages.join(', ')
    end
  end

  context 'length' do
    should 'pass validation if attribute between min and max' do
      @dummy_class.name = 'Maciek'
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'length' => { 'maximum' => 10, 'minimum' => 4 } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end

    should 'pass validation if attribute is blank' do
      # we have separate presence validator
      @dummy_class.name = ''
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'length' => { 'maximum' => 10, 'minimum' => 4 } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end

    should 'fail validation when not enough characters' do
      @dummy_class.name = 'abc'
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'length' => { 'maximum' => 10, 'minimum' => 4 } }
        )
      ).validate
      assert_equal 'Name is too short (minimum is 4 characters)', @dummy_class.errors.full_messages.join(', ')
    end

    should 'fail validation when too many characters' do
      @dummy_class.name = 'way too long string'
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'length' => { 'maximum' => 10, 'minimum' => 4 } }
        )
      ).validate
      assert_equal 'Name is too long (maximum is 10 characters)', @dummy_class.errors.full_messages.join(', ')
    end
  end

  context 'numericality' do
    should 'pass validation if attribute between min and max' do
      @dummy_class.name = 5.2
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'numericality' => { 'maximum' => 5.4, 'minimum' => 2.4 } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end

    should 'pass validation if attribute is blank' do
      @dummy_class.name = nil
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'numericality' => { 'maximum' => 5.4, 'minimum' => 2.4 } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end

    should 'fail validation when too small' do
      @dummy_class.name = 2
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'numericality' => { 'maximum' => 5.4, 'minimum' => 2.4 } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end

    should 'fail validation when too big' do
      @dummy_class.name = 7
      StandardValidator.new(
        argument_hash_with_rules(
          validation_rules: { 'numericality' => { 'maximum' => 5.4, 'minimum' => 2.4 } }
        )
      ).validate
      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end
  end

  protected

  def argument_hash_with_rules(hash = {})
    {
      record: @dummy_class,
      field_name: 'name',
      validation_rules: {}
    }.merge(hash)
  end
end
