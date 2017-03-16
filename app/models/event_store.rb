# frozen_string_literal: true
module EventStore
  def self.publish_event(event)
    Repository::Event.create!(
      event_type: event.event_type,
      payload: serialize(event.payload),
      triggered_by: event.triggered_by || system_user,
      topic_name: event.topic_name
    )
  end

  def self.serialize(object)
    EventDataSerializer.new(object).to_h
  end

  def self.system_user
    User.new(admin: true, name: 'System user')
  end
end
