# frozen_string_literal: true
module Shippings

  # TODO: mostly all functions from the module below should be extracted from ORDER
  # and moved to either VIEW-OBJECT or FORM-OBJECT like model
  module Order
    extend ActiveSupport::Concern

    included do
      has_many :deliveries, inverse_of: :order
      accepts_nested_attributes_for :deliveries

      # TODO: fix it - move to better place
      after_validation do
        if Shippings.enabled?(self) && inbound.present? && outbound.present?
          inbound.errors.each { |k,v| errors.add("inbound_#{k}", v)}
          outbound.errors.each { |k,v| errors.add("outbound_#{k}", v)}

          inbound_sender.errors.each { |k, v| errors.add("inbound_sender_#{k}", v) }
          outbound_receiver.errors.each { |k, v| errors.add("outbound_receiver_#{k}", v) }
        end
        true
      end

      # move to command
      def process_deliveries!
        # FIX: takes two last - should not contain more than allowed in shipping-profile
        deliveries.last(2).each do |delivery|
          shipping_order = client.place_order delivery

          # TODO: handle error properly
          # TODO: wrap response into response#delivery object
          raise shipping_order.body.inspect unless shipping_order.success?

          delivery.update_attributes(
            tracking_url: shipping_order.body['tracking_url'],
            order_reference: shipping_order.body['sendle_reference'],
            status: shipping_order.body['state']
          )
        end
      end

      def client
        Deliveries.courier name: provider.shipping_provider_name, settings: provider.test_settings
      end

      def provider
        instance.shipping_providers.first
      end

      def inbound
        deliveries.first
      end

      def outbound
        deliveries.last
      end

      def inbound_pickup_date=(date_string)
        @inbound_pickup_date = date_time_handler.convert_to_date(date_string)
        inbound.pickup_date = @inbound_pickup_date
      end

      def outbound_pickup_date=(date_string)
        @outbound_pickup_date = date_time_handler.convert_to_date(date_string)
        outbound.pickup_date = @outbound_pickup_date
      end

      def inbound_pickup_date
        date_time_handler.convert_to_string(@inbound_pickup_date.presence || inbound.pickup_date)
      end

      def outbound_pickup_date
        date_time_handler.convert_to_string(@outbound_pickup_date.presence || outbound.pickup_date)
      end

      def date_time_handler
        DateTimeHandler.new
      end

      delegate :address, :address=, :longitude, :longitude=, :latitude, :latitude=, to: :outbound_return_address, prefix: true
      delegate :address, :address=, :longitude, :longitude=, :latitude, :latitude=, to: :inbound_pickup_address, prefix: true

      def inbound_pickup_address_address=(address)
        inbound_pickup_address.formatted_address = address
      end

      def outbound_return_address_address=(address)
        outbound_return_address.formatted_address = address
      end

      def inbound_pickup_address
        inbound.sender_address.address
      end

      def outbound_return_address
        outbound.receiver_address.address
      end

      delegate :firstname=, :firstname, :lastname, :lastname=, to: :inbound_sender, prefix: true
      def inbound_sender
        inbound.sender_address
      end

      delegate :firstname=, :firstname, :lastname, :lastname=, to: :outbound_receiver, prefix: true
      def outbound_receiver
        outbound.receiver_address
      end
    end
  end
end
