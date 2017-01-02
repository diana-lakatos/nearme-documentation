# frozen_string_literal: true
class RequestParametersValidator
  SINGLE_PARAMETERS_TO_BE_CHECKED = %i(id page transactable_type_id group_type_id follower_id follower_type).freeze
  ARRAY_PARAMETERS_TO_BE_CHECKED = %i(topic_ids).freeze

  def initialize(params)
    @params = params.with_indifferent_access
  end

  def validate!
    raise InvalidParameterError unless valid_parameters?
  end

  protected

  def valid_parameters?
    valid_single_parameters? && valid_array_parameters?
  end

  def valid_single_parameters?
    SINGLE_PARAMETERS_TO_BE_CHECKED.all? { |key| valid_value?(@params[key]) }
  end

  def valid_array_parameters?
    ARRAY_PARAMETERS_TO_BE_CHECKED.all? { |array_key| array_contains_valid_values?(@params[array_key]) }
  end

  def array_contains_valid_values?(array)
    array.blank? || array.try(:all?) { |value| valid_integer?(value) }
  end

  def valid_value?(value)
    value.respond_to?(:to_i)
  end

  def valid_integer?(value)
    return true if value.blank?
    value.respond_to?(:to_i) && value.to_i.to_s == value
  end

  class InvalidParameterError < StandardError; end
end
