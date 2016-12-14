# frozen_string_literal: true
require 'test_helper'

class PasswordValidatorTest < ActiveSupport::TestCase
  class DummyClass
    include ActiveModel::Model

    attr_accessor :password
  end

  setup do
    @dummy_class = PasswordValidatorTest::DummyClass.new
  end

  context 'Object' do
    should 'be valid' do
      password_validation_rules = {
        'uppercase' => '1',
        'lowercase' => '1',
        'number' => '1',
        'symbol' => '1',
        'min_password_length' => '8'
      }

      @dummy_class.password = 'aA1@aA1@'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal '', @dummy_class.errors.full_messages.join(', ')
    end
  end

  context 'length' do
    should 'be based on instance.password_validation_rules' do
      password_validation_rules = {
        'uppercase' => '0',
        'lowercase' => '0',
        'number' => '0',
        'symbol' => '0',
        'min_password_length' => '8'
      }

      @dummy_class.password = 'aA1@'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal 'Password is too short (minimum is 8 characters)', @dummy_class.errors.full_messages.join(', ')
    end
  end

  context 'format' do
    should 'have one uppercase character' do
      password_validation_rules = {
        'uppercase' => '1',
        'lowercase' => '0',
        'number' => '0',
        'symbol' => '0',
        'min_password_length' => '6'
      }

      @dummy_class.password = 'aa11@@'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal 'Password should contain at least one capital letter', @dummy_class.errors.full_messages.join(', ')
    end

    should 'have one lowercase character' do
      password_validation_rules = {
        'uppercase' => '0',
        'lowercase' => '1',
        'number' => '0',
        'symbol' => '0',
        'min_password_length' => '6'
      }

      @dummy_class.password = 'AA11@@'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal 'Password should contain at least one small letter', @dummy_class.errors.full_messages.join(', ')
    end

    should 'have one number' do
      password_validation_rules = {
        'uppercase' => '0',
        'lowercase' => '0',
        'number' => '1',
        'symbol' => '0',
        'min_password_length' => '6'
      }

      @dummy_class.password = 'AAaa@@'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal 'Password should contain at least one number', @dummy_class.errors.full_messages.join(', ')
    end

    should 'have one symbol character' do
      password_validation_rules = {
        'uppercase' => '0',
        'lowercase' => '0',
        'number' => '0',
        'symbol' => '1',
        'min_password_length' => '6'
      }

      @dummy_class.password = 'AAaa11'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal 'Password should contain at least one symbol', @dummy_class.errors.full_messages.join(', ')
    end

    should 'have all rules passed' do
      password_validation_rules = {
        'uppercase' => '1',
        'lowercase' => '1',
        'number' => '1',
        'symbol' => '1',
        'min_password_length' => '6'
      }

      @dummy_class.password = 'aaaaa'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal 'Password should contain at least one capital letter, should contain at least one small letter, should contain at least one number, should contain at least one symbol, and is too short (minimum is 6 characters)', @dummy_class.errors.full_messages.join(', ')
    end
  end

  context 'defaults' do
    should 'have minimum characters length in password' do
      password_validation_rules = {}

      @dummy_class.password = 'aA1@'

      validation = PasswordValidator.new
      validation.stubs(:password_validation_rules).returns(password_validation_rules)
      validation.validate(@dummy_class)

      assert_equal 'Password is too short (minimum is 6 characters)', @dummy_class.errors.full_messages.join(', ')
    end
  end
end
