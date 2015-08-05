require 'message_bus'

# Mock class to use in development and test environments
class TestMessageBus
  class << self

    def message_handler
      @handler ||= Rails.configuration.message_bus_handler
    end

    def publish(channel, data, opts = nil)
      msg = MessageBus::Message.new(-1, 0, channel, data)
      if @tracking
        @tracking << msg
      else
        CacheExpiration.handle_cache_expiration(msg.data)
      end
      0
    end

    def track_publish
      @tracking = tracking =  []
      yield
      @tracking = nil
      tracking
    end

    def subscribe(channel,  &blk)
      {}
    end
  end
end
