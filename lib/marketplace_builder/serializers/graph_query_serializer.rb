module MarketplaceBuilder
  module Serializers
    class GraphQuerySerializer < BaseSerializer
      resource_name -> (g) { "graph_queries/#{g.name.underscore}" }

      property :content

      def content(graph_query)
        graph_query.query_string
      end

      def scope
        @model.graph_queries
      end
    end
  end
end
