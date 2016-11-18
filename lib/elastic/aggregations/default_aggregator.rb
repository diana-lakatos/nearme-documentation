module Elastic
  module Aggregations
    class DefaultAggregator < BaseAggregator
      def enabled?
        true
      end

      def fields
        [
          { label: :distinct_locations, type: :cardinality, field: :location_id },
          { label: :maximum_price, type: :max, field: :all_prices },
          { label: :minimum_price, type: :min, field: :all_prices }
        ]
      end
    end
  end
end
