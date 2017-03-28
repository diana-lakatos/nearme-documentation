# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      UserStatusUpdate = GraphQL::ObjectType.define do
        interfaces [ActivityFeed::EventSourceInterface]
        name 'ActivityFeedUserStatusUpdate'
        field :id, !types.Int
        field :body, types.String
        field :created_at, types.String
        field :updated_at, types.String
        field :text, types.String
        field :activity_feed_images, types[Types::Image] do
          resolve ->(obj, _arg, _ctx) { obj.activity_feed_images.map(&:image) }
        end
      end
    end
  end
end
