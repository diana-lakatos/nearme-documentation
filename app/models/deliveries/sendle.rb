# frozen_string_literal: true
module Deliveries
  # sendle API client NM adapter
  class Sendle < Base
    def initialize(settings:, logger: nil)
      raise ArgumentError, 'could not find valid settings for sendle shipping' if settings.nil?

      @settings = settings
      @logger = logger
    end

    delegate :ping, to: :client

    def get_quote(delivery)
      client.get_quote pickup_suburb:     delivery.sender_address_city,
                       pickup_postcode:   delivery.sender_address_postcode,
                       delivery_suburb:   delivery.receiver_address_city,
                       delivery_postcode: delivery.receiver_address_postcode,
                       kilogram_weight:   delivery.weight
    end

    def view_order(delivery)
      client.view_order order_id: delivery.order_reference
    end

    # TODO: update deivery status and order-reference
    def place_order(delivery)
      client.place_order PlaceOrder.new(delivery).to_params
    end

    def cancel_order(delivery)
      client.cancel_order(order_id: delivery.order_reference)
    end

    def track_parcel(delivery)
      client.track_parcel delivery.sendle_reference
    end

    def predefined_packages
      SendleApi::Packages.all
    end

    private

    def client
      @client = SendleApi::Client.new(
        sendle_id: @settings.fetch('sendle_id'),
        sendle_api_key: @settings.fetch('api_key'),
        environment: @settings.fetch('environment'),
        logger: @logger
      )
    end
  end
end
