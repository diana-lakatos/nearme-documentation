# frozen_string_literal: true
module Elastic
  module QueryBuilder
    # for local class requeirements of buildng
    # franco was a famous builder
    class Franco
      QUERY_BOOST = 1.0

      delegate :each, :empty?, :size, :slice, :[], :to_ary, :first, to: :results
      delegate :results, :total_entries, to: :collection

      attr_reader :types

      def initialize(query: {}, types: [])
        @query = query
        @types = types
      end

      def add(branch)
        @query.deep_merge!(branch.to_hash) do |_key, old, new|
          Array(old) + Array(new)
        end

        self
      end

      def document_types(*types)
        @types = types
      end

      def to_hash
        @query
      end

      private

      def collection
        @collection ||= Collection.new(response)
      end

      def response
        puts to_hash if ENV['DEBUG_ES']
        Fletcher.new(self).response
      end

      def default
        {
          query: {
            match_all: {
              boost: QUERY_BOOST
            }
          }
        }
      end
    end
  end
end
