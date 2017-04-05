# frozen_string_literal: true
module Graph
  module Types
    ShoppingCart = GraphQL::ObjectType.define do
      name 'ShoppingCart'

      global_id_field :id

      field :id, !types.ID

      field :orders, !types[Types::Order] do
        resolve ->(obj, _arg, _) { obj.orders }
      end
      field :checkout_at, types.String
      field :user, !Types::User do
        resolve ->(obj, _args, _ctx) { UserDrop.new(obj.user) }
      end
    end
  end
end
