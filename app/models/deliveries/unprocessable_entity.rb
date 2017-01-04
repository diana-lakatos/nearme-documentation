module Deliveries
  class UnprocessableEntity < StandardError
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def inspect
      message
    end

    def to_s
      message
    end
  end
end
