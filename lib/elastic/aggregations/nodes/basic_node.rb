# frozen_string_literal: true
module Elastic
  module Aggregations
    module Nodes
      # TODO: rename
      class BasicNode < Node
        def body
          {
            label => node(type => node(field: field), aggregations: aggregations)
          }
        end

        private

        def type
          @type || :terms
        end
      end
    end
  end
end
