# frozen_string_literal: true
module Graph
  module Types
    Company = GraphQL::ObjectType.define do
      name 'Company'
      description 'A firm'

      global_id_field :id

      field :id, !types.Int
      field :url, types.String
      field :name, !types.String
      field :description, types.String
    end
  end
end
