# frozen_string_literal: true
module Elastic
  module Aggregations
    class NestedAggregator < BaseAggregator
      def initialize(**_agrs)
        super(**args)

        @nested = nested
      end
    end
  end
end
