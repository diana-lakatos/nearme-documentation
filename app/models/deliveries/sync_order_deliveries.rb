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
      order.shipping_provider.api_client do |c|
        c.logger = Deliveries::RequestLogger.new(context: order)
      end
    end
  end
end
