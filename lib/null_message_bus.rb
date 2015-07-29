require 'message_bus'

# Mock class to use in development and test environments
class NullMessageBus
  class << self
    attr_accessor :redis_config

    def message_handler
      @handler ||= Rails.configuration.message_bus_handler
    end

    def publish(channel, data, opts = nil)
      if @tracking
        m = MessageBus::Message.new(-1, 0, channel, data)
        @tracking << m
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
