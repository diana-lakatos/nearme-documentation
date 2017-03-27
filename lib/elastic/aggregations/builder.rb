# frozen_string_literal: true
module Elastic
  # Builder.new.add name:, filters: {some: 'filters'}, fields: [{field: 'designer'}]
  module Aggregations
    class Builder
      attr_reader :body

      def initialize
        @body = {}
      end

      def add(name:, filters:, fields:, nested: false)
        add_node Aggregator.new(name: name, filters: filters, fields: fields, nested: nested)
      end

      # get rid of
      def add_default(name: :filtered_aggregations, filters:)
        add_node DefaultAggregator.new(name: name, filters: filters)
      end

      def add_global(name: :global, fields:) #
        add_node GlobalAggregator.new(name: name, fields: fields)
      end

      private

      def add_node(aggregator)
        @body.merge! aggregator.body if aggregator.enabled?
      end
    end
  end
end
