module Graph
  module Types
    Blog = GraphQL::ObjectType.define do
      name 'Blog'

      field :id, !types.ID
      field :name, types.String
      field :enabled, types.Boolean
    end
  end
end
