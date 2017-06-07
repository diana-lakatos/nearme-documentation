# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Commentable = GraphQL::ObjectType.define do
        name 'ActivityFeedCommentable'
        field :id, !types.Int
        field :creator_id, types.ID
        field :name, types.String
        field :url, types.String do
          resolve Graph::Resolvers::ResourceUrl.new
        end
      end
    end
  end
end
