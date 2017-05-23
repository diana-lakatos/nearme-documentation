# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class QueryResolver < BaseResolver
        def resolve
          resolve_arguments do |args|
            simple_query_string(args)
          end
        end

        private

        def simple_query_string(keyword)
          { query: { simple_query_string: { query: keyword, default_operator: 'and' } } }
        end
      end
    end
  end
end
