# frozen_string_literal: true
module Graph
  module Types
    RootQuery = GraphQL::ObjectType.define do
      name 'RootQuery'
      description 'Root query for schema'
      fields FieldCombiner.combine(
        [
          Types::CustomAttributes::CustomAttributeQueryType,
          ActivityFeed::FeedQueryType,
          LocationQueryType,
          MessagesQueryType,
          SearchQueryType,
          TopicQueryType,
          TransactableQueryType,
          UserQueryType,
          ShoppingCartQueryType,
          Orders::OrdersQueryType,
          WishListItemQueryType
        ]
      )
    end
  end
end
