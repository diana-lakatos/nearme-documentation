# frozen_string_literal: true
module Graph
  module Resolvers
    module AR
      class PageResolver < Graph::Resolvers::AR::BaseResolver
        def resolve
          resolve_arguments do |args|
            scope.paginate(page: args[:page], per_page: args[:per_page])
          end
        end
      end
    end
  end
end
