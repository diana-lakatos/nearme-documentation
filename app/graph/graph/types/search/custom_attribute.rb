# frozen_string_literal: true
module Graph
  module Types
    module Search
      CustomAttribute = GraphQL::ObjectType.define do
        name 'SearchCustomAttribute'
        description 'Custom attribute for search'

        field :name, types.String
        field :label_key, types.String
        field :lg_custom_attribute, types.String
        field :any_valid_values_translated, types.Boolean
        field :valid_values_translated, types[types.String]
      end
    end
  end
end
