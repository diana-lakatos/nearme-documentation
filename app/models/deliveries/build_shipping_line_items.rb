# frozen_string_literal: true
module Deliveries
  class BuildShippingLineItems
    def self.build(order:)
      new(order: order).prepare
    end

    def initialize(order:)
      @order = order
    end

    def prepare
      deliveries.map do |delivery|
        quote = get_quote(delivery)

        build_shipping_line_item line_item_source: delivery,
                                 name: delivery.class.to_s,
                                 quantity: 1,
                                 unit_price_cents: quote.gross,
                                 included_tax_total_rate: quote.tax,
                                 properties: quote,
                                 instance_id: @order.instance_id,
                                 receiver: 'mpo'
      end
    end

    private

    def build_shipping_line_item(attributes)
      @order.shipping_line_items.build(attributes)
    end

    def get_quote(delivery)
      client.get_quote(delivery)
    end

    def deliveries
      @order.deliveries
    end

    def client
      Deliveries.courier name: shipping_provider.shipping_provider_name,
                         settings: shipping_provider.settings,
                         logger: Deliveries::RequestLogger.new(context: @order)
    end

    def shipping_provider
      @order.shipping_provider
    end
  end
end
