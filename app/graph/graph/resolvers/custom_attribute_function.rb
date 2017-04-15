# frozen_string_literal: true
module Graph
  module Resolvers
    class CustomAttributeFunction < GraphQL::Function
      argument :name, GraphQL::STRING_TYPE
      type GraphQL::STRING_TYPE
      description 'Fetch any custom attribute by name, ex: hair_color: custom_attribute(name: "hair_color")'

      def resolve(obj, args, _ctx)
        obj.properties[args.name]
      end
    end
  end
end
