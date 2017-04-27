# frozen_string_literal: true
module Graph
  module Types
    OrdersQueryType = GraphQL::ObjectType.define do
      field :orders do
        type !types[Types::Order]
        argument :user_id, types.ID
        argument :creator_id, types.ID
        argument :archived, types.Boolean
        argument :state, types[Types::OrderStateEnum]
        argument :reviewable, types.Boolean
        resolve Resolvers::Orders.new
      end

      field :order do
        type !Types::Order
        argument :id, !types.ID
        argument :user_id, types.ID
        argument :creator_id, types.ID
        argument :state, types[Types::OrderStateEnum]
        resolve Resolvers::Order.new
      end
    end
  end
end
