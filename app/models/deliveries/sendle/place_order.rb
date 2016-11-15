# frozen_string_literal: true
module Deliveries
  class Sendle
    class PlaceOrder
      attr_reader :delivery

      def initialize(delivery)
        @delivery = delivery
      end

      def to_params
        {
          description: description,
          pickup_date: delivery.pickup_date,
          kilogram_weight: delivery.weight,
          sender: {
            contact: {
              name: sender_contact_name,
              email: delivery.sender_address.email
            },
            address: sender_address
          },
          receiver: {
            contact: {
              name: receiver_contact_name,
              email: delivery.receiver_address.email
            },
            address: receiver_address,
            instructions: delivery.notes
          }
        }
      end

      private

      def sender_address
        to_address(delivery.sender_address.address)
      end

      def receiver_address
        to_address(delivery.receiver_address.address)
      end

      def description
        format '[%s] from %s to %s', delivery.order.id, sender_contact_name, receiver_contact_name
      end

      def sender_contact_name
        delivery.sender_address.full_name
      end

      def receiver_contact_name
        delivery.receiver_address.full_name
      end

      def to_address(address)
        {
          address_line1: address.address,
          suburb: address.city,
          postcode: address.postcode,
          country: address.country,
          state_name: address.state
        }
      end
    end
  end
end
