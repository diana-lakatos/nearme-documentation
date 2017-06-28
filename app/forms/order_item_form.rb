# frozen_string_literal: true
class OrderItemForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration)
      end
    end
  end
end
