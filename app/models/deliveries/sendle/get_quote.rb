# frozen_string_literal: true
module Deliveries
  class Sendle
    class GetQuote
      attr_reader :client, :delivery

      def initialize(delivery, client)
        @delivery = delivery
        @client = client
      end

      def perform
        make_request
        process_response
      end

      private

      def process_response
        Shippings::Quote.new @response
      end

      def make_request
        @response = client.get_quote pickup_suburb:     delivery.sender_address_suburb,
                                     pickup_postcode:   delivery.sender_address_postcode,
                                     delivery_suburb:   delivery.receiver_address_suburb,
                                     delivery_postcode: delivery.receiver_address_postcode,
                                     kilogram_weight:   delivery.weight
      end
    end
  end
end
