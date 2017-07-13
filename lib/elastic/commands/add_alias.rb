# frozen_string_literal: true
module Elastic
  module Commands
    class AddAlias
      def initialize(index:, alias_name:)
        @index = index
        @alias_name = alias_name
      end

      def perform
        connection.post '_aliases', options.to_json
      end

      private

      def connection
        client.transport.get_connection.connection
      end

      def options
        {
          actions:
            [
              {
                add: { alias: @alias_name, index: @index.name }
              }
            ]
        }
      end

      def client
        Elastic::Configuration.current.client
      end
    end
  end
end
