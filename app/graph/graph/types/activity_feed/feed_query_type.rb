# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      FeedQueryType = GraphQL::ObjectType.define do
        field :feed do
          type !ActivityFeed::Feed
          argument :object_id, !types.ID
          argument :object_type, !types.String
          argument :include_user_feed, types.Boolean
          argument :page, types.Int
          resolve Graph::Resolvers::Feed
        end

        connection :comments, Graph::Types::RelayConnection.build(Types::ActivityFeed::Comment) do
          argument :since, types.Int, 'A Unix timestamp'
          resolve Resolvers::Comments.new
        end
      end
    end
  end
end
