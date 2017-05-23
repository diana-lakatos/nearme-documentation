# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class SortGroupResolver < BaseResolver
        private

        def resolve
          resolve_each_argument do |argument|
            SortItemResolver.new.call(self, argument, ctx)
          end
        end
      end

      class SortItemResolver < BaseResolver
        private

        def resolve
          resolve_argument :key do |value, node|
            { sort: { value => { order: node[:order] } } }
          end
        end
      end
    end
  end
end
