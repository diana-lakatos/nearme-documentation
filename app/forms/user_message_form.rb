# frozen_string_literal: true
class UserMessageForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_custom_attributes(configuration)
        inject_dynamic_fields(configuration, whitelisted: [:body, :replying_to_id])
      end
    end
  end
end
