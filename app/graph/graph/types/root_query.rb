# frozen_string_literal: true
module Graph
  module Types
    RootQuery = GraphQL::ObjectType.define do
      name 'RootQuery'
      description 'Root query for schema'
      fields FieldCombiner.combine(
        [
          FeedQueryType,
          LocationQueryType,
          MessagesQueryType,
          SearchQueryType,
          TopicQueryType,
          TransactableQueryType,
          UserQueryType
        ]
      )
    end
  end
end
