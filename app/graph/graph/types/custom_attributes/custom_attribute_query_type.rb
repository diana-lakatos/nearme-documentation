# frozen_string_literal: true
module Graph
  module Types
    module CustomAttributes
      CustomAttributeQueryType = GraphQL::ObjectType.define do
        field :custom_attribute_definition do
          type ::Graph::Types::CustomAttributes::CustomAttributeDefinition
          argument :name, !types.String
          resolve ->(_obj, args, _ctx) { ::CustomAttributes::CustomAttribute.find_by(name: args[:name]) }
        end
      end
    end
  end
end
