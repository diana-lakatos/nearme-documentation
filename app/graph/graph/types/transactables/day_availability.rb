# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      DayAvailability = GraphQL::ObjectType.define do
        name 'DayAvailability'

        field :day, !types.Int
        field :day_name, types.String
        field :availability, !types[Types::Transactables::Availability]
      end
    end
  end
end
