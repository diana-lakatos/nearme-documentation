# frozen_string_literal: true
module Elastic
  module QueryBuilder
    # for local class requeirements of buildng
    # franco was a famous builder
    class Franco
      attr_reader :query

      def initialize(query = {})
        @query = query
      end

      def add(branch)
        @query.deep_merge!(branch) do |_key, old, new|
          Array(old) + Array(new)
        end
      end

      def to_h
        @query.reverse_merge(default)
      end

      private

      def default
        {
          query: {
            match_all: {
              boost: QueryBuilderBase::QUERY_BOOST
            }
          }
        }
      end
    end
  end
end
