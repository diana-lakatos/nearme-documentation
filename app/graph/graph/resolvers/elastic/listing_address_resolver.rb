# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class ListingAddressResolver < BaseResolver
        private

        def resolve
          resolve_argument :city do |value|
            match_field(:city, value)
          end

          resolve_argument :country do |value|
            match_field(:country, value)
          end

          resolve_argument :street do |value|
            match_field(:street, value)
          end

          resolve_argument :state do |value|
            match_field(:state, value)
          end

          resolve_argument :suburb do |value|
            match_field(:suburb, value)
          end
        end

        def match_field(field, value)
          {
            filter: {
              bool: {
                must: [
                  { match: { "address.#{field}" => value } }
                ]
              }
            }
          }
        end
      end
    end
  end
end
