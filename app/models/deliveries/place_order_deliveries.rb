module Deliveries
  class PlaceOrderDeliveries
    # this is kind of validation - ensure only allowed number of orders is places
    # this should be moved to order or transactable and should depend on process type
    # two deliveries - return
    # one delivery - purchase
    # TODO: there should be also be a model validation
    RETURN_DELIVERY_TYPE = 2

    attr_reader :order

    def initialize(order)
      @order = order
    end

    def perform
      deliveries.map { |delivery| client.place_order(delivery) }
    end

    private

    def deliveries
      @order.deliveries.last(RETURN_DELIVERY_TYPE)
    end

    def client
      order.shipping_provider.api_client do |c|
        c.logger = Deliveries::RequestLogger.new(context: order)
      end
    end
  end
end
