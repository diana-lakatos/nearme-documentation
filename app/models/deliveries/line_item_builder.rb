module Deliveries
  class LineItemBuilder
    attr_reader :delivery

    def self.build(delivery)
      new(delivery).build
    end

    def initialize(delivery)
      @delivery = delivery
    end

    def build
      {
        line_item_source: delivery,
        name: delivery.class.to_s,
        quantity: 1,
        unit_price_cents: quote.gross,
        included_tax_total_rate: quote.tax,
        properties: quote,
        instance_id: delivery.instance_id,
        receiver: 'mpo'
      }
    end

    def quote
      @quote ||= get_quote(delivery)
    end

    def get_quote(delivery)
      build_quote client.get_quote(delivery)
    end

    def build_quote(response)
      EnhancedQuote.new(response).tap do |q|
        q.extra_fee = delivery.shipping_provider.mpo_extra_shipping_fee
      end
    end

    def client
      delivery.shipping_provider.api_client do |c|
        c.logger = Deliveries::RequestLogger.new(context: @order)
      end
    end

    class EnhancedQuote < SimpleDelegator
      attr_accessor :extra_fee
      def gross
        super + extra_fee
      end
    end
  end
end
