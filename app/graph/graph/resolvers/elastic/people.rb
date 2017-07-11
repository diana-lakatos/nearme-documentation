# frozen_string_literal: true
module Graph
  module Resolvers
    module Elastic
      class People < BaseResolver
        private

        def resolve
          document_types :user

          resolve_arguments do |args|
            Graph::Resolvers::Elastic::PageResolver.new.call(self, args, ctx)
          end

          resolve_argument :sort do |value|
            Graph::Resolvers::Elastic::SortGroupResolver.new.call(self, value, ctx)
          end

          resolve_argument :query do |value|
            Graph::Resolvers::Elastic::QueryResolver.new.call(self, value, ctx)
          end

          resolve_argument :user do |value|
            Graph::Resolvers::Elastic::ListingResolver.new.call(self, value, ctx)
          end
        end
      end
    end
  end
end
