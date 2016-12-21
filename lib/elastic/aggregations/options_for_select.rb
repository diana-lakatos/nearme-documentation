# frozen_string_literal: true
module Elastic
  module Aggregations
    class OptionsForSelect
      def self.build(aggregations, key: :custom_attributes)
        new(aggregations, key: key).build
      end

      # combine two sets of aggregations
      # default without filters
      # and filtered one into one in a way:
      # { red: 5, blue: 3, green: 7 } and { red: 3 } => { red: 3, blue: 0, green: 0 }
      def self.prepare(aggregations)
        global = build(aggregations, key: :global)
        custom = build(aggregations)

        global.each_with_object({}) do |(key, values), agg|
          agg[key] = merge(values, custom[key])
        end
      end

      def self.merge(global, custom)
        global.map do |b|
          custom.find(-> { if_missing(b) }) { |a| a.key == b.key }
        end
      end

      def self.if_missing(copy)
        Elastic::Aggregations::OptionsForSelect::Buckets::Bucket.new(copy.key, 0)
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
        @aggregations
          .fetch(@key, [])
          .reject { |key, _value| key == 'doc_count' }
      end

      class Buckets
        def initialize(buckets)
          @buckets = buckets
        end

        def options
          @buckets
            .map { |bucket| Bucket.new(bucket['key'], bucket['doc_count']) }
            .select(&:display?)
        end

        class Bucket
          attr_accessor :key, :value

          def initialize(key, value)
            @key = key
            @value = value
          end

          def label
            key
          end

          def label_with_value
            return key if value.zero?
            format('%s (%s)', key, value).strip
          end

          def display?
            key.present?
          end

          def disabled
            value.zero?
          end
        end
      end
    end
  end
end
