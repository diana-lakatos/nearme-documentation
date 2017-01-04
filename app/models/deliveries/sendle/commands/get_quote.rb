# frozen_string_literal: true
module Deliveries
  class Sendle
    module Commands
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

        def make_request
          @response = client.get_quote pickup_suburb:     delivery.sender_address_suburb,
                                       pickup_postcode:   delivery.sender_address_postcode,
                                       delivery_suburb:   delivery.receiver_address_suburb,
                                       delivery_postcode: delivery.receiver_address_postcode,
                                       kilogram_weight:   delivery.weight
        end

        def process_response
          raise Deliveries::UnprocessableEntity, @response.body unless @response.success?

          ::Deliveries::Quote.new @response
        end

      end
    end
  end
end
