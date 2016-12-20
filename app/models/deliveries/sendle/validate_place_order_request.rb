module Deliveries
  class Sendle
    class ValidatePlaceOrderRequest
      attr_reader :delivery, :errors

      def initialize(delivery)
        @delivery = delivery
        @errors = []
      end

      def valid?
        client.place_order(delivery)
      rescue Deliveries::Sendle::PlaceOrder::UnprocessableEntity => e
        @errors = parse_error_response e.message
        @errors.empty?
      end

      private

      # this mess could be sorted by using form-objects
      # inbound_sender.address.errors.each { |k, v| errors.add("inbound_pickup_address_#{k}", v) }
      # outbound_receiver.address.errors.each { |k, v| errors.add("outbound_return_address_#{k}", v) }
      def parse_error_response(message)
        {
          pickup_date: message.dig('messages', 'pickup_date'),
          'pickup_address_state' => Array(message.dig('messages', 'sender', 0, 'address', 0, 'state_name')).join(', '),
          'return_address_state' => Array(message.dig('messages', 'receiver', 0, 'address', 0, 'state_name')).join(', ')
        }
      end

      def client
        @client = Deliveries.courier(name: 'sendle', settings: settings, logger: logger)
      end

      def settings
        {
          'api_key' => 'BBXmdgVKwxy4Yvz5yCRrJjSX',
          'sendle_id' => 'darek_near_me_com',
          'environment' => 'test'
        }
      end

      def logger
        SanboxRequestsLogger.new(context: nil)
      end

      class SanboxRequestsLogger < Deliveries::RequestLogger
        def formatted_message(type, message)
          format('[SANBOX][%s] %s', type, message)
        end
      end
    end
  end
end
