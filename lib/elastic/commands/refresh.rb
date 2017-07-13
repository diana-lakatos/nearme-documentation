# frozen_string_literal: true
module Elastic
  module Commands
    class Refresh
      def initialize(from:, to:)
        @from = from
        @to = to
      end

      def perform
        client.reindex body: { source: { index: @from }, dest: { index: @to } }
      end

      private

      def client
        Elastic::Configuration.current.client
      end
    end
  end
end
