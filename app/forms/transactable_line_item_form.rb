# frozen_string_literal: true
class TransactableLineItemForm < BaseForm
  model LineItem::Transactable

  property :_destroy, virtual: true

  def _destroy=(value)
    model.mark_for_destruction if checked?(value)
  end

  def _destroy
    '1' if model.marked_for_destruction?
  end

  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration, whitelisted: [:name, :description, :quantity, :unit_price])
      end
    end
  end
end
