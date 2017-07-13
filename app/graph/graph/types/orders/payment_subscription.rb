# frozen_string_literal: true
module Graph
  module Types
    module Orders
      PaymentSubscription = GraphQL::ObjectType.define do
        name 'PaymentSubscription'

        global_id_field :id

        field :id, !types.ID
        field :expired_at, types.String
      end
    end
  end
end
