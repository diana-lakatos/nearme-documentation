module Elastic
  module Aggregations
    class NestedAggregator < BaseAggregator
      def initialize(**agrs)
        super(**args)

        @nested = nested
      end
    end
  end
end
