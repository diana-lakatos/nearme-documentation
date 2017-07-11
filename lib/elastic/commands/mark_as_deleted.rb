module Elastic
  module Commands
    class MarkAsDeleted
      attr_reader :record

      delegate :client, :index_name, to: :configuration

      def initialize(record)
        @record = record
      end

      def call
        return unless doc_type

        index_record
      end

      private

      def index_record
        client.update record_params
      end

      def record_params
        default_params.merge body: { doc: { deleted_at: record.deleted_at } },
                             index: index_name,
                             type: document_type,
                             id: record.id
      end

      def default_params
        return {} unless parent_id

        { parent: record.public_send(parent_id) }
      end

      def parent_id
        doc_type.parent
      end

      def doc_type
        configuration.doc_types[document_type]
      end

      def document_type
        record.class.document_type
      end

      def configuration
        @configuration ||= Elastic::Configuration.current
      end
    end
  end
end
