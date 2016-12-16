# frozen_string_literal: true
module Deliveries
  class Sendle
    class PlaceOrder
      def initialize(delivery, client)
        @delivery = delivery
        @client = client
      end

      def perform
        make_request
        process_response
      end

      def make_request
        @response = @client.place_order request_params
      end

      def request_params
        PlaceOrderParams.build(@delivery)
      end

      def process_response
        raise @response.body.inspect unless @response.success?

        PlaceOrderResponse.new(@response)
      end
    end

    # this should have an interface:
    # @tracking_url
    # @order_reference
    # @status
    class PlaceOrderResponse
      def initialize(response)
        @response = response
      end

      def tracking_url
        body['tracking_url']
      end

      def order_reference
        body['sendle_reference']
      end

      def status
        body['state']
      end

      private

      def body
        @response.body
      end
    end
  end
end
