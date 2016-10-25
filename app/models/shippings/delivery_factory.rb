# frozen_string_literal: true
module Shippings
  class DeliveryFactory
    def self.build(order:)
      [
        InboundDeliveryFactory.new(order: order).build,
        OutboundDeliveryFactory.new(order: order).build
      ]
    end

    class BaseDeliveryFactory
      def initialize(order:)
        @order = order
      end

      def build
        @order.deliveries.build attributes
      end

      def delivery_estimate
        2
      end

      def attributes
        {
          sender_address: sender_address,
          receiver_address: receiver_address,
          pickup_date: pickup_date,
          order: @order,
          order_id: @order.id
        }
      end

      def lister_address
        OrderAddress.new firstname: lister.first_name,
                         lastname: lister.last_name,
                         email: lister.email,
                         phone: lister.full_mobile_number,
                         address: user_address
      end

      def user_address
        address = OrderListerAddress.new(@order.host).find
        address.fetch_address!
        address.dup
      end

      def lister
        @order.transactable.creator
      end

      def starts_at
        @order.starts_at.in_time_zone(@order.time_zone)
      end

      def ends_at
        @order.ends_at.in_time_zone(@order.time_zone)
      end

      class OrderListerAddress
        def initialize(user)
          @user = user
        end

        def find
          company_location_address || shipping_address || billing_address
        end

        private

        def billing_address
          @user.billing_addresses.first&.address
        end

        def shipping_address
          @user.shipping_addresses.first&.address
        end

        def company_location_address
          @user.locations.last&.location_address
        end
      end
    end

    class InboundDeliveryFactory < BaseDeliveryFactory
      # TODO: better way of estimating delivery
      # - based on distance
      # - business days only
      def pickup_date
        starts_at.advance(days: -delivery_estimate)
      end

      def receiver_address
        @order.shipping_address
      end

      def sender_address
        lister_address
      end
    end

    class OutboundDeliveryFactory < BaseDeliveryFactory
      def pickup_date
        ends_at.advance(days: +1)
      end

      def receiver_address
        lister_address
      end

      def sender_address
        @order.shipping_address
      end
    end
  end
end
