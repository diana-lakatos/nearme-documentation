# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Event = GraphQL::ObjectType.define do
        name 'ActivityFeedEvent'
        description 'Event for a feed'

        global_id_field :id

        field :id, !types.Int
        field :creator_id, types.ID
        field :followed, Followed
        field :name, types.String
        field :description, types.String
        field :event, types.String
        field :has_body, types.Boolean
        field :event_source, ActivityFeed::EventSource
        field :event_source_type, types.String
        field :is_status_update_event, types.Boolean
        field :is_comment_event, types.Boolean
        field :is_photo_event, types.Boolean
        field :is_reportable, types.Boolean
        field :created_at, types.String
        field :header_image, types.String
        field :details, Details do
          resolve ->(event, args, _ctx) { ActivityFeedService::Event.new(event, args[:target]) }
        end
        field :url, types.String do
          resolve Resolvers::ResourceUrl.new
        end
        field :comments, types[Types::ActivityFeed::Comment]
      end
    end
  end
end
