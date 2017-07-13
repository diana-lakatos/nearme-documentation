# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      OfferAction = GraphQL::ObjectType.define do
        name 'OfferAction'

        global_id_field :id

        field :id, !types.ID
        field :pricings, !types[Types::Transactables::Pricing]
      end
    end
  end
end
