# frozen_string_literal: true
module Elastic
  module Aggregations
    module Nodes
      # TODO: rename
      class Terms < Node
        DEFAULT_ORDER = { _term: 'asc' }.freeze

        def body
          {
            label => node(type => node(field: field, size: size, order: order), aggregations: aggregations)
          }
        end

        def order
          @order || DEFAULT_ORDER
        end

        private

        def type
          @type || :terms
        end
      end
    end
  end
end
