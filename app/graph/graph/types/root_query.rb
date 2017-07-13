# frozen_string_literal: true
module Graph
  module Types
    RootQuery = GraphQL::ObjectType.define do
      name 'RootQuery'
      description 'Root query for schema'

      # Please add new query types in namespace of a feature
      fields FieldCombiner.combine(
        [
          Graph::Types::ActivityFeed::FeedQueryType,
          Graph::Types::Authentications::LoginProvidersQueryType,
          Graph::Types::CategoriesQueryType,
          Graph::Types::CreditCards::CreditCardQueryType,
          Graph::Types::CustomAttributes::CustomAttributeQueryType,
          Graph::Types::LocationQueryType,
          Graph::Types::MessagesQueryType,
          Graph::Types::Orders::OrdersQueryType,
          Graph::Types::Photos::PhotoQueryType,
          Graph::Types::Queries::Listings,
          Graph::Types::ShoppingCartQueryType,
          Graph::Types::TopicQueryType,
          Graph::Types::Transactables::TransactableQueryType,
          Graph::Types::UserQueryType,
          Graph::Types::WishListItemQueryType,
          Graph::Types::Customizations::CustomizationQueryType
        ]
      )
    end
  end
end
