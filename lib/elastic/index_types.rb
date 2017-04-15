module Elastic
  module IndexTypes
    class SimpleIndex
      def body
        {
          mappings: mappings,
          settings: settings
        }
      end

      def mappings
        sources.each_with_object({}) do |source, maps|
          maps.merge! source.mappings
        end
      end

      def settings
        { index: { number_of_shards: 1 } }
      end
    end

    class MultipleModel
      attr_reader :sources

      def initialize(sources:)
        @sources = sources
      end

      def body
        {
          mappings: mappings,
          settings: settings
        }
      end

      private

      def mappings
        sources.each_with_object({}) do |source, maps|
          maps.merge! source.mappings
        end
      end

      def settings
        { index: { number_of_shards: 1 } }
      end
    end
  end
end
