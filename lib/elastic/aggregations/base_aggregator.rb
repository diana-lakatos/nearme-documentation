module Elastic
  module Aggregations
    class BaseAggregator
      attr_reader :fields

      def initialize(name:, filters:, fields: [], nested: false)
        @name = name
        @filters = filters
        @fields = fields
        @nested = nested

        @aggregations = {}
      end

      def enabled?
        @fields.any?
      end

      def body
        {
          @name => { filter: filter, aggregations: aggregations }
        }
      end

      def filter
        { bool: { must: @filters } }
      end

      def aggregations
        aggregation_fields.each_with_object({}) do |field, aggs|
          aggs.merge! field.body
        end
      end

      def aggregation_fields
        fields.map(&method(:create_field))
      end

      def create_field(field)
        Nodes::Terms.new(field)
      end
    end
  end
end
