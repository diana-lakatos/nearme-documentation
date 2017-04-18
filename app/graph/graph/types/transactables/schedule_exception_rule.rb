
# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      ScheduleExceptionRule = GraphQL::ObjectType.define do
        name 'ScheduleExceptionRule'

        global_id_field :id

        field :id, !types.Int
        field :duration_range_start, !types.String
        field :duration_range_end, !types.String
      end
    end
  end
end
