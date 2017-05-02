# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      Pricing = GraphQL::ObjectType.define do
        name 'Pricing'

        global_id_field :id

        field :id, !types.Int
        field :number_of_units, !types.String
        field :unit, !types.String
        field :price, !types.Float
        field :price_cents, !types.Int
        field :currency, !types.String
        field :min_price, types.String
        field :max_price, types.String
        field :transactable_type_pricing, Types::TransactableTypes::Pricing
      end
    end
  end
end
