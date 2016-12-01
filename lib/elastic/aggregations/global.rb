module Elastic
  module Aggregations
    class Global
      def initialize(data)
        @data = data
        @body = {}
      end

      def enabled?
        @data.any?
      end

      def body
        @data.each do |agg|
          add agg[:label], Field.new(agg[:field])
        end

        build
      end

      def build
        { global: {}, aggs: @body }
      end

      private

      def add(key, aggregator)
        aggregator.enabled? && @body[key] = aggregator.body
      end
    end
  end
end
