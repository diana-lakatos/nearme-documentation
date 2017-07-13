# frozen_string_literal: true
module Graph
  module Types
    Category = GraphQL::ObjectType.define do
      name 'Category'
      description 'Category'

      global_id_field :id

      field :id, !types.Int
      field :permalink, !types.String
      field :name, !types.String
      field :name_of_root, types.String
      field :position, types.Int
      field :is_root, types.Boolean
      field :slug, !types.String
    end
  end
end
