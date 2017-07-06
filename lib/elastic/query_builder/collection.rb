# frozen_string_literal: true
module Elastic
  module QueryBuilder
    class Collection
      attr_reader :total_entries

      def initialize(response)
        @response = response
      end

      def total_entries
        @response.dig('hits', 'total')
      end

      def results
        @response
          .dig('hits', 'hits')
          .map { |source| source_factory(source) }
      end

      def source_factory(source)
        case source.fetch('_type')
        when 'user'
          Elastic::SourceTypes::UserSource.new(source['_source'])
        when 'transactable'
          # FIXME
          Elastic::SourceTypes::TransactableSource.new source['_source'].merge creator: source.dig('inner_hits', 'user', 'hits', 'hits', 0, '_source')
        else
          raise 'could not find resource type for: ' + source
        end
      end
    end
  end
end
