# frozen_string_literal: true
module Graph
  module Types
    Address = GraphQL::ObjectType.define do
      name 'Address'
      description 'An address'

      global_id_field :id

      field :id, !types.Int
      field :city, !types.String
      field :state, !types.String
    end
  end
end
