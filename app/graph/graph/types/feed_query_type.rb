module Graph
  module Types
    FeedQueryType = GraphQL::ObjectType.define do
      field :feed do
        type !Types::Feed
        resolve Resolvers::Feed
      end
    end
  end
end
