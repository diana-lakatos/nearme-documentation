# frozen_string_literal: true
module Elastic
  module Commands
    class Import
      def initialize(index:, doc_type:)
        @index = index
        @doc_type = doc_type
      end

      def perform
        ActiveRecord::Base.logger.silence do
          print_import_details
          import_documents
        end
      end

      def print_import_details
        puts format('Importing %d items from %s', source.count, source.name)
      end

      private

      def import_documents
        source.import import_params
      end

      def import_params
        {
          scope: @doc_type.scope,
          batch_size: 150,
          index: @index.name,
          transform: transform
        }
      end

      def source
        @doc_type.source
      end

      def transform
        Transform.new(@doc_type).prepare
      end

      class Transform
        def initialize(doc_type)
          @doc_type = doc_type
        end

        def prepare
          return default_transform unless @doc_type.parent

          lambda do |model|
            {
              index: {
                _id: model.id,
                parent: model.public_send(@doc_type.parent),
                data: model.__elasticsearch__.as_indexed_json
              }
            }
          end
        end

        def default_transform
          @doc_type.source.__elasticsearch__.__transform
        end
      end
    end
  end
end
