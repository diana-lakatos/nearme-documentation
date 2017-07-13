# frozen_string_literal: true
module Graph
  module Types
    module Customizations
      Customizable = GraphQL::UnionType.define do
        name 'Customizable'

        possible_types [
          Types::Transactables::Transactable,
          Types::Orders::Order,
          Types::Users::Profile
        ]
      end
    end
  end
end
