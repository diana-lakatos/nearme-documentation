module Elastic
  module Aggregations
    class GlobalAggregator < BaseAggregator
      def initialize(name:, fields: [])
        @fields = fields
        @name = name

        @aggregations = {}
      end

      def body
        {
          @name => { global: {}, aggregations: aggregations }
        }
      end
    end
  end
end
