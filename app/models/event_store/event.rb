# frozen_string_literal: true
module EventStore
  class Event
    attr_reader :payload, :triggered_by, :topic_name

    def initialize(payload:, triggered_by:, event_type: nil, topic_name: nil)
      @payload = payload
      @triggered_by = triggered_by
      @topic_name = topic_name
      @event_type = event_type
    end

    def event_type
      (@event_type || self.class).to_s
    end
  end
end
