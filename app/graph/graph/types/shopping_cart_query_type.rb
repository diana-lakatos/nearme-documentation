# frozen_string_literal: true
module Graph
  module Types
    ShoppingCartQueryType = GraphQL::ObjectType.define do
      field :shopping_cart do
        type !Types::ShoppingCart
        argument :id, !types.ID
        argument :user_id, types.ID
        argument :checked_out, types.Boolean
        resolve Resolvers::ShoppingCart.new
      end
    end
  end
end
