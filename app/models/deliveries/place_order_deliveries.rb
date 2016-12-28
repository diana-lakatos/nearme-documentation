module Deliveries
  class PlaceOrderDeliveries
    attr_reader :order

    def initialize(order)
      @order = order
    end

    def perform
      @order
        .deliveries
        .last(2)
        .map { |delivery| client.place_order(delivery) }
    end

    def client
      @client ||= shipping_client
    end

    def shipping_client
      Deliveries.courier name: shipping_provider.shipping_provider_name,
                         settings: shipping_provider.settings,
                         logger: Deliveries::RequestLogger.new(context: order)
    end

    def shipping_provider
      order.shipping_provider
    end
  end
end
