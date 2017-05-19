# frozen_string_literal: true
class UserMessageForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration)
      end
    end
  end
end
