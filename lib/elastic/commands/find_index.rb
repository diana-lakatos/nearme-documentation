# frozen_string_literal: true
module Elastic
  module Commands
    class FindIndex
      def initialize(name:)
        @name = name
      end

      def perform
        data.any? && build_index
      end

      private

      def build_index
        name = data.keys.first
        body = data[name]

        Elastic::Index.new name: name,
                           body: {
                             aliases: body['aliases'],
                             mappings: body['mappings'],
                             settings: body['settings']
                           },
                           alias_name: body['aliases'].keys.first,
                           version: name.split('-').last.to_i
      end

      def data
        indices.get index: @name
      end

      def indices
        client.indices
      end

      def client
        Elastic::Configuration.current.client
      end
    end
  end
end
