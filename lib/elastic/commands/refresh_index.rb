# frozen_string_literal: true
module Elastic
  module Commands
    # Make changes available for search
    # https://www.elastic.co/guide/en/elasticsearch/reference/5.0/indices-refresh.html
    class RefreshIndex
      def initialize(model)
        @model = model
      end

      def call
        client.refresh_index!
      end

      private

      def client
        @model.__elasticsearch__
      end
    end
  end
end
