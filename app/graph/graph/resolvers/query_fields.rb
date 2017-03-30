# frozen_string_literal: true
module Graph
  module Resolvers
    class QueryFields
      def initialize(query)
        @query = query
      end

      def to_h
        traverse(@query.children)
      end

      private

      def traverse(nodes)
        nodes.each_with_object({simple: [], nested: {}}) do |node, h|
          if node.children.empty?
            h[:simple] << node.name
          else
            h[:nested][node.name] = traverse(node.children)
          end
        end
      end
    end
  end
end
