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
      Deliveries::Sendle::Commands::GetQuote.new(delivery, client).perform
    end

    def place_order(delivery)
      Deliveries::Sendle::Commands::PlaceOrder.new(delivery, client).perform
    end

    def sync_order(delivery)
      Deliveries::Sendle::Commands::SyncDelivery.new(delivery, client).perform
    end

    def cancel_order(delivery)
      Deliveries::Sendle::Commands::CancelDelivery.new(delivery, client).perform
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
