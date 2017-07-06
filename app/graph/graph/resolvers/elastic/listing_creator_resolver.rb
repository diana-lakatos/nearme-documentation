# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class ListingCreatorResolver < BaseResolver
        private

        def resolve
          resolve_arguments do
            {
              filter: {
                bool: {
                  must: [
                    {
                      has_parent: {
                        inner_hits: {
                          _source: %w(name first_name last_name slug id),
                          size: 1
                        },
                        parent_type: 'user',
                        query: { match_all: {} }
                      }
                    }
                  ]
                }
              }
            }
          end
        end
      end
    end
  end
end
