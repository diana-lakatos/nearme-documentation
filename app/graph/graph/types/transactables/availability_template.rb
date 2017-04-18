# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      AvailabilityTemplate = GraphQL::ObjectType.define do
        name 'AvailabilityTemplate'

        global_id_field :id

        field :id, !types.Int
        field :availability_rules, types[Types::Transactables::AvailabilityRule]
        field :schedule_exception_rules, types[Types::Transactables::ScheduleExceptionRule]
      end
    end
  end
end
