# frozen_string_literal: true
module Graph
  module Types
    module Transactables
      TimeBasedBooking = GraphQL::ObjectType.define do
        name 'TimeBasedBooking'

        global_id_field :id

        field :id, !types.Int
        field :minimum_booking_minutes, !types.Int
        field :availability_template, Types::AvailabilityTemplate
        field :pricings, !types[Types::Transactables::Pricing]
      end
    end
  end
end
