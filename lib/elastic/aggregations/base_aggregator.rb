module Elastic
  module Aggregations
    class BaseAggregator
      attr_reader :fields

      def initialize(name:, filters:, fields: [])
        @filters = filters
        @fields = fields
        @name = name

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
        Field.new(label: field[:label], field: field[:field], type: field[:type])
      end
    end
  end
end
