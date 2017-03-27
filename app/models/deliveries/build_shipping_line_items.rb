# frozen_string_literal: true
module Deliveries
  class BuildShippingLineItems
    def self.build(**params)
      new(**params).prepare
    end

    attr_reader :shipping_provider

    def initialize(order:)
      @order = order
    end

    def prepare
      build_line_items
      apply_refund
    end

    private

    def build_line_items
      @order.deliveries.each do |delivery|
        add_line_item LineItemBuilder.build(delivery)
      end
    end

    # TODO: move out to strategy
    # the-volte flow - do not change lister for manual shipping
    # and give $$$ back
    def apply_refund
      @order
        .shipping_line_items
        .select { |item| item.line_item_source.courier == 'auspost-manual' && item.line_item_source.outbound? }
        .each { |item| item.unit_price_cents = item.unit_price_cents * -1 }
    end

    def add_line_item(attributes)
      @order.shipping_line_items.build(attributes)
    end
  end
end
