# frozen_string_literal: true
module Graph
  module Types
    module Orders
      ReservationPeriod = GraphQL::ObjectType.define do
        name 'ReservationPeriod'

        global_id_field :id

        field :id, !types.Int
        field :reservation, !Types::Orders::Order
        field :date, !types.String
        field :start_minute, types.Int
        field :end_minute, types.Int
      end
    end
  end
end
