# frozen_string_literal: true
module Graph
  module Types
    module CreditCards
      CreditCard = GraphQL::ObjectType.define do
        name 'CreditCard'
        description 'Stored Credit Card'

        global_id_field :id

        field :id, !types.ID
        field :name, types.String
        field :default_card, types.Boolean
        field :instance_client_id, types.ID
      end
    end
  end
end
