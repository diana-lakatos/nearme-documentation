# frozen_string_literal: true
class V3::ActivityFeedEventJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :event
  attribute :followed_id
  attribute :followed_type
  attribute :affected_objects_identifiers
  attribute :event_source_id
  attribute :event_source_type
  attribute :created_at
end
