# frozen_string_literal: true
module Elastic
  module Aggregations
    class OptionsForSelect
      def self.build(aggregations, key: :custom_attributes)
        new(aggregations, key: key).build
      end

      def initialize(aggregations, key:)
        @aggregations = aggregations
        @key = key
      end

      def build
        aggregations.each_with_object({}) do |(field_name, field_data), agg|
          agg[field_name] = Buckets.new(field_data.buckets).options
        end
      end

      def aggregations
        @aggregations[@key]
          .reject { |key, _value| key == 'doc_count' }
      end

      class Buckets
        def initialize(buckets)
          @buckets = buckets
        end

        def options
          @buckets
            .map { |bucket| [label(bucket), bucket['key']] }
            .select { |label, _value| label.present? }
        end

        def label(bucket)
          format('%s (%s)', bucket['key'], bucket['doc_count']).strip
        end
      end
    end
  end
end
