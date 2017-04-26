# frozen_string_literal: true
module Graph
  module Types
    module AvailabilityTemplates
      AvailabilityRule = GraphQL::ObjectType.define do
        name 'AvailabilityRule'

        global_id_field :id

        field :id, !types.Int
        field :days, types[types.Int]
        field :open_hour, types.Int
        field :open_minute, types.Int
        field :close_hour, types.Int
        field :close_minute, types.Int
      end
    end
  end
end
