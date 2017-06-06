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

        field :comments, Graph::Types::Collection.build(Types::ActivityFeed::Comment) do
          argument :since, types.Int, 'A Unix timestamp'
          argument :paginate, Types::PaginationParams, default_value: { page: 1, per_page: 10 }
          resolve Resolvers::Comments.new
        end
      end
    end
  end
end
