# frozen_string_literal: true
class AvailabilityRuleForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  property :id
  property :_destroy, virtual: true

  property :open_time
  property :close_time
  property :days
end
