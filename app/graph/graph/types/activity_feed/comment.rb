# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Comment = GraphQL::ObjectType.define do
        interfaces [ActivityFeed::EventSourceInterface]
        name 'ActivityFeedComment'
        field :id, !types.Int
        field :body, types.String
        field :created_at, types.String
        field :updated_at, types.String
        field :commented_own_thread, types.Boolean do
          resolve ->(comment, _arg, _ctx) { ActivityFeedHelper.commented_own_thread?(comment) }
        end
        field :url, types.String do
          resolve ->(comment, _arg, _ctx) { UrlHelper.new.polymorphic_path([comment.commentable, comment]) }
        end
        field :activity_feed_images, types[Types::Image] do
          resolve ->(comment, _arg, _ctx) { comment.activity_feed_images.map(&:image) }
        end
        field :creator, Types::User do
          resolve ->(obj, _arg, _ctx) { Resolvers::Users.decorate(obj.creator) }
        end
        field :commentable, ActivityFeed::Commentable
      end
    end
  end
end
