# frozen_string_literal: true
module Graph
  module Types
    ShoppingCart = GraphQL::ObjectType.define do
      name 'ShoppingCart'

      global_id_field :id

      field :id, !types.ID

      field :orders, !types[Types::Orders::Order] do
        resolve ->(obj, _arg, _) { obj.orders }
      end
      field :checkout_at, types.String
      field :user, !Types::User do
        resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, {id: obj.user_id }, ctx) }
      end
    end
  end
end
