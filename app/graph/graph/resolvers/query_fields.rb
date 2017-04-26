# frozen_string_literal: true
module Graph
  module Resolvers
    class QueryFields
      def initialize(query)
        @query = query
      end

      def to_h
        nodes = @query.children
        nodes = nodes.first.children unless nodes.first.respond_to?(:name)
        traverse(nodes)
      end

      private

      def traverse(nodes)
        nodes.each_with_object(simple: [], nested: {}) do |node, h|
          extract_fields(node, h)
        end
      end

      def extract_fields(node, h)
        if node.children.empty?
          h[:simple] << node.name
        else
          h[:nested][node.name] = traverse(node.children)
        end
      end
    end
  end
end
