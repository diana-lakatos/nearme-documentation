# Mock class to use in development environment
class NullMessageBus
  class << self

    def message_handler
      @handler ||= Rails.configuration.message_bus_handler
    end

    def publish(channel, data, opts = nil)
      CacheExpiration.handle_cache_expiration(data)
      0
    end

    def subscribe(channel,  &blk)
      {}
    end
  end
end
