# frozen_string_literal: true
class OrderItemForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (transactable_line_items_configuration = configuration.delete(:transactable_line_items))
          add_validation(:transactable_line_items, transactable_line_items_configuration)
          collection :transactable_line_items, form: TransactableLineItemForm.decorate(transactable_line_items_configuration),
                                               populate_if_empty: LineItem::Transactable,
                                               prepopulator: ->(_options) { transactable_line_items << build_transactable_line_item if transactable_line_items.empty? }
        end
        inject_dynamic_fields(configuration, whitelisted: [:state_event, :comment, :period_start_date, :period_end_date, :currency, :rejection_reason, :ends_at, :starts_at])

        def build_transactable_line_item
          model.transactable_line_items.new
        end
      end
    end
  end
end
