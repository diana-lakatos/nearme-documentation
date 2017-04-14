# frozen_string_literal: true
module Graph
  module Types
    ReservationPeriod = GraphQL::ObjectType.define do
      name 'ReservationPeriod'

      global_id_field :id

      field :id, !types.Int
      field :reservation, !Types::Order
      field :date, !types.String
      field :start_minute, types.Int
      field :end_minute, types.Int
    end
  end
end
