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
      @order.deliveries.map do |delivery|
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
      build_quote client.get_quote(delivery)
    end

    def build_quote(response)
      EnhancedQuote.new(response).tap do |q|
        q.extra_fee = shipping_provider.mpo_extra_shipping_fee
      end
    end

    def client
      shipping_provider.api_client do |c|
        c.logger = Deliveries::RequestLogger.new(context: @order)
      end
    end

    def shipping_provider
      @order.shipping_provider
    end

    class EnhancedQuote < SimpleDelegator
      attr_accessor :extra_fee
      def gross
        super + extra_fee
      end
    end
  end
end
