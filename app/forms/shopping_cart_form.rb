# frozen_string_literal: true
class ShoppingCartForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections

  class << self
    def decorate(configuration)
      Class.new(self) do
        if (orders_configuration = configuration.delete(:orders)).present?
          validation = orders_configuration.delete(:orders)
          validates :orders, validation if validation.present?
          property :orders, form: OrdersForm.decorate(orders_configuration),
                            from: :orders_open_struct
        end
      end
    end
  end
end
