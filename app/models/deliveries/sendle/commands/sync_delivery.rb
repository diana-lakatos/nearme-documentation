module Deliveries
  class Sendle
    module Commands
      class SyncDelivery
        attr_reader :delivery

        def initialize(delivery, client)
          @delivery = delivery
          @client = client
        end

        def perform
          make_request
          process_response
          store_external_state
        end

        def make_request
          @response = @client.view_order order_id: delivery.external_order_id
        end

        def process_response
          raise Deliveries::UnprocessableEntity, @response.body unless @response.success?
        end

        def store_external_state
          delivery.external_states.create body: @response.body, instance_id: delivery.instance_id
        end
      end
    end
  end
end
