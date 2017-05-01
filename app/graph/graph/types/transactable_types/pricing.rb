# frozen_string_literal: true
module Graph
  module Types
    module TransactableTypes
      Pricing = GraphQL::ObjectType.define do
        name 'TransactableTypePricing'

        global_id_field :id

        field :id, !types.Int
        field :service_fee_guest_percent, !types.Float
        field :service_fee_host_percent, !types.Float
      end
    end
  end
end
