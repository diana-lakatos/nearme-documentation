# frozen_string_literal: true
module Deliveries
  class DeliveryFactory
    DEFAULT_MESSAGE = 'no notes'

    def self.build(order:, shipping_provider:)
      [
        InboundDeliveryFactory.new(order: order, shipping_provider: shipping_provider, direction: 'inbound').build,
        OutboundDeliveryFactory.new(order: order, shipping_provider: shipping_provider, direction: 'outbound').build
      ]
    end

    class BaseDeliveryFactory
      def initialize(order:, shipping_provider:, direction:)
        @order = order
        @shipping_provider = shipping_provider
        @direction = direction
      end

      def build
        @order.deliveries.build(attributes).tap do |delivery|
          delivery.add_validator delivery_validator
        end
      end

      def delivery_validator
        Deliveries::Validations::Delivery.new
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
          order_id: @order.id,
          dimensions_template_id: dimensions_template.id,
          courier: @shipping_provider.shipping_provider_name,
          notes: notes,
          direction: @direction
        }
      end

      # TODO: need a better approach
      # sendle requires notes for every package but A4
      def notes
        return if dimensions_template.name == 'Satchel'

        DEFAULT_MESSAGE
      end

      def lister_address
        OrderAddress.new firstname: lister.first_name,
                         lastname: lister.last_name,
                         email: lister.email,
                         phone: lister.full_mobile_number,
                         address: lister_detailed_address
      end


      # TODO: setting validation should be handled bit better
      # 1. shipping-provider should provide us with banch of custom validators
      # kind a registry { validations: { sendle: [validator#1, validator#2]}}
      # and this could be handled by form-builder with its validators
      def lister_detailed_address
        address = OrderListerAddress.new(@order.host).find
        address.raw_address = true
        address.dup.tap do |add|
          add.add_validator Deliveries::Sendle::Validations::Address.new if @shipping_provider.shipping_provider_name == 'sendle'
        end
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

      def dimensions_template
        @order.transactable.dimensions_template
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
