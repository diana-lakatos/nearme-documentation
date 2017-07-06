# frozen_string_literal: true
module Graph
  module Types
    Customization = GraphQL::ObjectType.define do
      name 'Customization'
      interfaces [Graph::Types::CustomAttributeInterface]
    end
  end
end
