# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      TransactableLineItem = GraphQL::ObjectType.define do
        name 'TransactableLineItem'

        global_id_field :id

        field :id, !types.Int
        field :name, types.String
        field :description, types.String
        field :created_at, !types.String
        field :unit_price_cents, !types.Int
        field :unit_price, !types.String
        field :total_price_cents, !types.Int
        field :total_price, !types.String
        field :quantity, !types.Float
        field :created_at, !types.String
        field :reviews, !types[Types::Review] do
          argument :user_id, types.ID
          resolve lambda { |obj, arg, _ctx|
            reviews = obj.reviews
            reviews = reviews.where(user_id: arg[:user_id]) if arg[:user_id]
            reviews
          }
        end
      end
    end
  end
end
