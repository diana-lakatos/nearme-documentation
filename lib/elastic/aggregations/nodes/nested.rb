# frozen_string_literal: true
module Elastic
  module Aggregations
    module Nodes
      class Nested < Node
        def body
          node label => node(nested: { path: path }, aggregations: aggregations)
        end
      end
    end
  end
end
