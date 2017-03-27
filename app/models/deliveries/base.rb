# frozen_string_literal: true
module Deliveries
  class Base
    attr_accessor :logger

    def predefined_packages
      []
    end

    def get_quote(delivery)
      raise NotImplementedError
    end

    def place_order(delivery)
      raise NotImplementedError
    end

    def sync_order(delivery)
      raise NotImplementedError
    end

    def cancel_order(delivery)
      raise NotImplementedError
    end

    def fetch_label(label_url)
      raise NotImplementedError
    end

    def track_parcel(delivery)
      raise NotImplementedError
    end
  end
end
