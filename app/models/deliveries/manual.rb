module Deliveries
  class Manual < Base
    def initialize(logger:, name:)
      @logger = logger
      @name = name
    end

    def get_quote(_delivery)
      Deliveries::Manual::Quote.new quote
    end

    def place_order(delivery)
    end

    def sync_order(delivery)
    end

    def cancel_order(delivery)
    end

    def fetch_label(label_url)
    end

    def track_parcel(delivery)
    end

    private

    def config
      Deliveries::Provider.find(@name)
    end

    def quote
      config['quote'].symbolize_keys
    end
  end
end
