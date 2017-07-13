# frozen_string_literal: true
module Graph
  module Types
    module Orders
      RecurringBookingPeriod = GraphQL::ObjectType.define do
        name 'RecurringBookingPeriod'

        global_id_field :id

        field :id, !types.ID
        field :order, !Types::Orders::Order
        field :period_start_date, types.String
        field :period_end_date, types.String
        field :paid_at, types.String
        field :state, types.String
        field :starts_at, types.String
        field :ends_at, types.String
        field :currency, types.String
        field :comment, types.String
        field :rejection_reason, types.String
        field :total_amount, types.String
        field :total_amount_cents, types.Int
        field :transactable_line_items, types[Types::Transactables::TransactableLineItem]
      end
    end
  end
end
