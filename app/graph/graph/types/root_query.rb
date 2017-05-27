# frozen_string_literal: true
module Graph
  module Types
    RootQuery = GraphQL::ObjectType.define do
      name 'RootQuery'
      description 'Root query for schema'

      # Please add new query types in namespace of a feature
      fields FieldCombiner.combine(
        [
          Types::CustomAttributes::CustomAttributeQueryType,
          FeedQueryType,
          LocationQueryType,
          MessagesQueryType,
          SearchQueryType,
          TopicQueryType,
          Transactables::TransactableQueryType,
          UserQueryType,
          ShoppingCartQueryType,
          Orders::OrdersQueryType,
          WishListItemQueryType
        ]
      )
    end
  end
end
