# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class ListingLocationResolver < ListingAddressResolver
        private

        def parent_field(field, value)
          {
            filter: {
              has_parent: {
                type: 'location',
                filter: {
                  bool: {
                    must: [
                      { match: { field => value } }
                    ]
                  }
                }
              }
            }
          }
        end
      end
    end
  end
end
