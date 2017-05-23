# frozen_string_literal: true
module Graph
  module Types
    module TransactableTypes
      TransactableType = GraphQL::ObjectType.define do
        name 'TransactableType'

        global_id_field :id

        field :id, !types.ID
        field :name, !types.String
      end
    end
  end
end
