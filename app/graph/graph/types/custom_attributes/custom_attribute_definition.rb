# frozen_string_literal: true
module Graph
  module Types
    module CustomAttributes
      CustomAttributeDefinition = GraphQL::ObjectType.define do
        name 'CustomAttributeDefinition'
        description 'Definition of Custom attribute'

        field :name, types.String
        field :attribute_type, types.String
        field :label, types.String do
          deprecation_reason 'Use translations'
        end
        field :valid_values, types[types.String] do
          deprecation_reason 'Use constants in liquid'
        end
      end
    end
  end
end
