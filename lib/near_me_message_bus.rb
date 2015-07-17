# Wrapper for MessageBus or other pub/sub library
class NearMeMessageBus
  class << self

    def message_handler
      unless @handler
        @handler = Rails.configuration.message_bus_handler
        @handler.redis_config = DesksnearMe::Application.config.redis_settings if @handler.redis_config.present?
      end
      @handler
    end

    def publish(channel, msg, opts = nil)
      msg.merge!({instance_id: PlatformContext.current.instance.id}) if PlatformContext.current
      message_handler.publish channel, msg, opts
    end

    def subscribe(channel,  &blk)
      message_handler.subscribe channel do |msg|
        if msg.data.is_a? Hash
          msg.data = msg.data.with_indifferent_access
          Instance.find(msg.data[:instance_id]).set_context! if msg.data[:instance_id]
        end

        yield msg
      end
    end

    def track_publish
      message_handler.track_publish do
        yield
      end
    end

  end
end
