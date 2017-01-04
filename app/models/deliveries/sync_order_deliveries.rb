module Deliveries
  class SyncOrderDeliveries
    attr_reader :order

    def initialize(order)
      @order = order
    end

    def perform
      sync_deliveries
    end

    private

    def sync_deliveries
      order
        .deliveries
        .map { |delivery| client.sync_order delivery }
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
