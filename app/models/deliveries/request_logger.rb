module Deliveries
  class RequestLogger
    def initialize(context:)
      @context = context
    end

    def info(message)
      log(:info, message)
    end

    def debug(message)
      log(:debug, message)
    end

    private

    def log(type, message)
      ExternalApiRequest.create(context: @context, body: formatted_message(type, message))
    end

    def formatted_message(type, message)
      format('[%s] %s', type, message)
    end
  end
end
