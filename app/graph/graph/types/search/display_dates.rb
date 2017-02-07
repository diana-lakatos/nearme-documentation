# frozen_string_literal: true
module Graph
  module Types
    module Search
      DisplayDates = GraphQL::ObjectType.define do
        name 'DisplayDates'
        description 'Dates'

        field :start, types.String do
          resolve ->(obj, _args, _ctx) { obj[:start] }
        end
        field :end, types.String do
          resolve ->(obj, _args, _ctx) { obj[:end] }
        end
      end
    end
  end
end
