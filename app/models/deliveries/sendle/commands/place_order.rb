module Deliveries
  class Sendle
    module Commands
      class PlaceOrder
        def initialize(delivery, client)
          @delivery = delivery
          @client = client
        end

        def perform
          make_request
          process_response
          store_external_state if @delivery.persisted?
        end

        def make_request
          @response = @client.place_order request_params
        end

        def request_params
          Params.build(@delivery)
        end

        def process_response
          raise Deliveries::UnprocessableEntity, @response.body unless @response.success?
        end

        def store_external_state
          @delivery.external_states.create! body: @response.body, instance_id: @delivery.instance_id
        end
      end
    end
  end
end
