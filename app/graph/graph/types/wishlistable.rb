# frozen_string_literal: true
module Graph
  module Types
    Wishlistable = GraphQL::UnionType.define do
      name 'Wishlistable'
      possible_types [
        Types::User,
        Types::Location,
        Types::Transactables::Transactable
      ]
    end
  end
end
