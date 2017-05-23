# frozen_string_literal: true
module Graph
  module Types
    Categories = GraphQL::ObjectType.define do
      field :categories, types[Category] do
        argument :name_of_root, types.String

        resolve Graph::Resolvers::Categories.new
      end
    end
  end
end
