# frozen_string_literal: true
module Commands
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
      Shippings::Quote.new(client.get_quote(delivery))
    end

    def deliveries
      @order.deliveries
    end

    def client
      Deliveries.courier name: provider.shipping_provider_name,
                         settings: provider.settings,
                         logger: Deliveries::RequestLogger.new(context: @order)

    end

    # TODO: this should be determined from order itself
    # user should be able to pick the best provider during chechout
    def provider
      @order.instance.shipping_providers.last
    end
  end
end
