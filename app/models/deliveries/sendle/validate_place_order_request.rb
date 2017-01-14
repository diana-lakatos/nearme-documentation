# workaround for sendle
# making request to sandbox environment with real user data
# in order to validate correctness of dates and places
# before making real request to production env
module Deliveries
  class Sendle
    class ValidatePlaceOrderRequest
      attr_reader :delivery, :errors

      def initialize(delivery)
        @delivery = delivery
        @errors = []
      end

      def valid?
        @response ||= client.place_order(delivery)
      rescue Deliveries::UnprocessableEntity => e
        @errors = parse_error_response e.message
        @errors
          .reject! { |_k, value| value.empty? }
          .empty?
      end

      private

      # this mess could be sorted by using form-objects
      # inbound_sender.address.errors.each { |k, v| errors.add("inbound_pickup_address_#{k}", v) }
      # outbound_receiver.address.errors.each { |k, v| errors.add("outbound_return_address_#{k}", v) }
      def parse_error_response(message)
        {
          pickup_date: message.dig('messages', 'pickup_date').join(', '),
          'pickup_address_state' => Array(message.dig('messages', 'sender', 0, 'address', 0, 'state_name')).join(', '),
          'return_address_state' => Array(message.dig('messages', 'receiver', 0, 'address', 0, 'state_name')).join(', ')
        }
      end

      # TODO: could have shipping-provider created with name: 'validator'
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
