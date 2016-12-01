module Elastic
  # Builder.new.add name:, filters: {some: 'filters'}, fields: [{field: 'designer'}]
  module Aggregations
    class Builder
      attr_reader :body

      def initialize
        @body = {}
      end

      def add(name:, filters:, fields:)
        add_node Aggregator.new(name: name, filters: filters, fields: fields)
      end

      # get rid of
      def add_default(name: :filtered_aggregations, filters:)
        add_node DefaultAggregator.new(name: name, filters: filters)
      end

      private

      def add_node(aggregator)
        @body.merge! aggregator.body if aggregator.enabled?
      end
    end
  end
end
