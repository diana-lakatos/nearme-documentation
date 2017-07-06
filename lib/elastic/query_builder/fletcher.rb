# frozen_string_literal: true
# internal builder class
module Elastic
  module QueryBuilder
    class Fletcher
      delegate :index_name, :client, to: :configuration

      def initialize(builder)
        @builder = builder
      end

      def response
        @response ||= client.search index: index_name, type: type, body: body
      end

      private

      def body
        @builder.to_hash
      end

      def type
        @builder.types.join ','
      end

      def configuration
        ::Elastic::Configuration.current
      end
    end
  end
end
