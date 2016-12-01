module Elastic
  module Aggregations
    class Field
      BUCKET_SIZE = 25

      def initialize(label:, field:, type: :terms)
        @field = field
        @label = label
        @type = type || :terms
      end

      def enabled?
        @field.present?
      end

      def body
        {
          @label => {
            @type => field_meta
          }
        }
      end

      def field_meta
        { field: @field }.tap do |data|
          data.merge! size: BUCKET_SIZE if bucket?
        end
      end

      def bucket?
        @type == :terms
      end
    end
  end
end
