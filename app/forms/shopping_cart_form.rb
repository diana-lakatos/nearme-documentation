# frozen_string_literal: true
class ShoppingCartForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  class << self
    def decorate(configuration)
      Class.new(self) do
        if (orders_configuration = configuration.delete(:orders)).present?
          add_validation(:orders, orders_configuration)
          property :orders, form: OrdersForm.decorate(orders_configuration),
                            from: :orders_open_struct
        end
        inject_dynamic_fields(configuration)
      end
    end
  end
end
