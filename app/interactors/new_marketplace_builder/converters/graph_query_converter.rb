# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class GraphQueryConverter < BaseConverter
      primary_key :name
      properties :name
      property :content

      def content(graph_query)
        graph_query.query_string
      end

      def set_content(graph_query, value)
        graph_query.query_string = value
      end

      def scope
        GraphQuery.where(instance_id: @model.id)
      end
    end
  end
end
