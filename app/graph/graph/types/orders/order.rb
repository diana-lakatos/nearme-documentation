# frozen_string_literal: true
module Graph
  module Types
    module Orders
      Order = GraphQL::ObjectType.define do
        name 'Order'
        implements GraphQL::Relay::Node.interface

        global_id_field :id

        field :id, !types.ID
        field :user, !Types::User do
          resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.creator_id }, ctx) }
        end
        field :creator, !Types::User do
          resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.creator_id }, ctx) }
        end
        field :transactable, !Types::Transactable do
          resolve ->(obj, _args, _ctx) { TransactableDrop.new(obj.transactable) }
        end
        field :transactable_line_items, !types[Types::Transactables::TransactableLineItem]
        field :currency, !types.String
        field :total_amount_cents, !types.Int
        field :subtotal_amount_cents, !types.Int
        field :service_fee_amount_guest_cents, !types.Int
        field :service_fee_amount_host_cents, !types.Int
        field :service_fee_amount_host_cents, !types.Int
        field :total_payable_to_host_cents, !types.Int
        field :time_zone, !types.String
        field :rejection_reason, !types.String
        field :lister_confirmed_at, !types.String
        field :enquirer_confirmed_at, !types.String
        field :state, Types::Orders::OrderStateEnum
        field :archived_at, types.String
        field :ends_at, types.String
        field :starts_at, types.String
        field :created_at, types.String
        field :custom_attribute, !types.String,
              'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")' do
          argument :name, !types.String
          resolve ->(obj, arg, _ctx) { obj.properties[arg[:name]] }
        end
        field :periods, types[Types::Orders::ReservationPeriod] do
          resolve ->(obj, _arg, _) { obj.try(:periods) }
        end
      end

      OrderStateEnum = GraphQL::EnumType.define do
        name 'OrderState'
        description 'List of available states for Order'
        value('inactive', 'Order which has not been checked out yet.')
        value('unconfirmed', "Order which has been checked out and is pending lister's manual confirmation.")
        value('confirmed', 'Order which has been checkouted out and was confirmed by lister.')
        value('cancelled_by_guest', 'Order which has been cancelled by Enquirer.')
        value('cancelled_by_host', 'Order which has been cancelled by Lister.')
        value('expired', 'Order which has expired due to not being confirmed by Lister within given time.')
        value('rejected', 'Order which has been checked out but has been rejected instead of being confirmed.')
        value('completed', 'Order which has been checked out, confirmed and now is completed.')
        value('archived', 'Order which has been archived. In theory this and completed should be the same.')
      end
    end
  end
end
