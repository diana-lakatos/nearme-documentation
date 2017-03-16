# frozen_string_literal: true
module Elastic
  module Aggregations
    module Nodes
      class Filter < Node
        def body
          {
            label => { filter: filter, aggregations: aggregations }
          }
        end
      end
    end
  end
end
