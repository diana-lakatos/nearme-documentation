module Metadata
  module InstanceMetadata
    extend ActiveSupport::Concern

    included do
      def populate_support_metadata!
        update_metadata(support_metadata: build_support_metadata)
      end

      def build_support_metadata
        reload.tickets.metadata.reorder(nil).collect { |t| { t.state => t.count.to_i } } + [{ 'total' => reload.tickets.count }]
      end
    end
  end
end
