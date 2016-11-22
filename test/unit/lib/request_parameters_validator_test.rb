require 'test_helper'

class RequestParametersValidatorTest < ActiveSupport::TestCase
  test 'raising error when one of the single attribute contains invalid value' do
    assert_raise RequestParametersValidator::InvalidParameterError do
      RequestParametersValidator.new(example_single_attribute_key => { a: :b }).validate!
    end
  end

  test 'raising error when one of the array attribute contains invalid value' do
    assert_raise RequestParametersValidator::InvalidParameterError do
      RequestParametersValidator.new(example_single_attribute_key => [{ a: :b }]).validate!
    end
  end

  test 'not raising error when one of the irrelevant attribute contains invalid value' do
    assert_nothing_raised do
      RequestParametersValidator.new(example_irrelevant_key => { a: :b }).validate!
    end
  end

  test 'not raising error when valid values are passed' do
    assert_nothing_raised do
      RequestParametersValidator.new(
        example_array_attribute_key => ['1', nil, ''],
        example_single_attribute_key => '1',
        example_single_attribute_key(1) => nil,
        example_single_attribute_key(2) => 'valid',
        example_single_attribute_key(3) => ''
      ).validate!
    end
  end

  test 'not raising error when one of the array attribute is nil' do
    assert_nothing_raised do
      RequestParametersValidator.new(example_array_attribute_key => nil).validate!
    end
  end

  test 'not raising error when one of the single attribute is nil' do
    assert_nothing_raised do
      RequestParametersValidator.new(example_single_attribute_key => nil).validate!
    end
  end

  protected

  def example_single_attribute_key(index = 0)
    RequestParametersValidator::SINGLE_PARAMETERS_TO_BE_CHECKED[index]
  end

  def example_array_attribute_key(index = 0)
    RequestParametersValidator::ARRAY_PARAMETERS_TO_BE_CHECKED[index]
  end

  def example_irrelevant_key
    'i am VUP - very unimportant parameter'
  end
end
