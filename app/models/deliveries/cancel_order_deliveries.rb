module Deliveries
  class CancelOrderDeliveries
    attr_reader :order
    RETURN_DELIVERY_TYPE = 2

    def initialize(order)
      @order = order
    end

    def perform
      deliveries.map { |delivery| client.cancel_order(delivery) }
    end

    private

    def deliveries
      @order.deliveries.last(RETURN_DELIVERY_TYPE)
    end

    def client
      @order.shipping_provider.api_client do |c|
        c.logger = Deliveries::RequestLogger.new(context: order)
      end
    end
  end
end
