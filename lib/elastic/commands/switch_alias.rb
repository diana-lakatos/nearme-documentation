# frozen_string_literal: true
module Elastic
  module Commands
    class SwitchAlias
      def initialize(from:, to:)
        @from = from
        @to = to
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
              { remove: { alias: @from.alias_name, index: @from.name } },
              { add:    { alias: @to.alias_name,   index: @to.name } }
            ]
        }
      end

      def client
        Elasticsearch::Model.client
      end
    end
  end
end
