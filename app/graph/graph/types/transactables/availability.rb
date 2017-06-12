# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      Availability = GraphQL::ObjectType.define do
        name 'Availability'

        field :minute, types.String
        field :quantity, types.Int
      end
    end
  end
end
