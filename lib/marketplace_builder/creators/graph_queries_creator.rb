# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class GraphQueriesCreator < TemplatesCreator
      def cleanup!
        @instance.graph_queries.destroy_all
        logger.debug 'Removing previous graph queries'
      end

      private

      def object_name
        'GraphQuery'
      end

      def create!(query)
        gq = @instance.graph_queries.where(name: query.liquid_path).first_or_initialize
        gq.update!(query_string: query.body)
      end

      def success_message(query)
        logger.debug "Creating graph query: #{query.liquid_path}"
      end
    end
  end
end
