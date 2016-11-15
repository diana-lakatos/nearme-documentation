module Commands
  class BuildShippingLineItems
    def initialize(order:)
      @order = order
    end

    def prepare
      @order.deliveries.map do |delivery|
        quote = Shippings::Quote.new(client.get_quote(delivery))

        @order.shipping_line_items.build line_item_source: delivery,
                                         name: delivery.to_s,
                                         quantity: 1,
                                         unit_price_cents: quote.gross,
                                         included_tax_total_rate: quote.tax,
                                         properties: quote,
                                         instance_id: @order.instance_id,
                                         receiver: 'mpo'
      end
    end

    def client
      Deliveries.courier name: provider.shipping_provider_name,
                         settings: provider.test_settings
    end

    # TODO: this should be determined from order itself
    # user should be able to pick the best provider during chechout
    def provider
      @order.instance.shipping_providers.last
    end
  end
end
