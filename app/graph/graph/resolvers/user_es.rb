# frozen_string_literal: true
module Graph
  module Resolvers
    class UserEs
      def initialize(query:, ctx:)
        @query = query
        @ctx = ctx
        @graph_field = ctx.field.name
      end

      def fetch
        Elastic::UserCollectionProxy
          .new(::User.simple_search(elastic_query))
          .results
          .map(&:to_liquid)
      end

      private

      NESTED_FIELDS_SOURCE_MAPPING = {
        'profile' => 'user_profiles.*',
        'current_address' => 'current_address.*'
      }.freeze

      def elastic_query
        {
          source: source_mapper,
          query: @query
        }
      end

      def query_fields
        @query_fields ||= Resolvers::QueryFields.new(@ctx.ast_node).to_h
      end

      def source_mapper
        source_fields = query_fields[:simple]
        source_fields << NESTED_FIELDS_SOURCE_MAPPING.slice(*query_fields[:nested].keys).values
        source_fields.flatten.compact
      end
    end
  end
end
