# frozen_string_literal: true
module Graph
  module Types
    FeedQueryType = GraphQL::ObjectType.define do
      field :feed do
        type !Types::Feed
        argument :include_user_feed, types.Boolean
        argument :page, types.Int
        resolve Resolvers::Feed
      end
    end
  end
end
