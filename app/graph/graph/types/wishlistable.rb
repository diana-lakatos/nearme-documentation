# frozen_string_literal: true
module Graph
  module Types
    Wishlistable = GraphQL::UnionType.define do
      name 'Wishlistable'
      possible_types [
        Graph::Types::User,
        Graph::Types::Location,
        Graph::Types::Transactables::Transactable
      ]
    end
  end
end
