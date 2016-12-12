# frozen_string_literal: true
module Graph
  module Types
    Instance = GraphQL::ObjectType.define do
      name 'Instance'
      description 'Instance'

      global_id_field :id

      field :id, !types.ID
      field :name, !types.String
      connection :locations, Types::Location.connection_type
    end
  end
end
