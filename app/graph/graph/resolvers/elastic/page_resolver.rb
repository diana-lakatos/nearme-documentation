# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class PageResolver < BaseResolver
        private

        def resolve
          resolve_arguments do |args|
            {
              size: args[:per_page],
              from: (args[:page] - 1) * args[:per_page]
            }
          end
        end
      end
    end
  end
end
