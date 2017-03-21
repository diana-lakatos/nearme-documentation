# frozen_string_literal: true
module Validatable
  extend ActiveSupport::Concern

  included do
    attr_reader :validator_list

    def add_validator(validator)
      validator_list << validator
    end

    def valid?(context = nil)
      super
      validator_list.each { |validator| validator.validate(self) }
      errors.empty?
    end

    private

    def validator_list
      @validator_list ||= []
    end
  end
end
