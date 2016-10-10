module Metadata
  module Support
    module TicketMetadata
      extend ActiveSupport::Concern

      included do
        delegate :populate_support_metadata!, to: :instance
        delegate :populate_user_support_metadata!, to: :user, allow_nil: true
        after_commit :populate_support_metadata!, if: :should_populate_instance_metadata?
        after_commit :populate_user_support_metadata!, if: :should_populate_user_metadata?

        def should_populate_instance_metadata?
          %w(created_at deleted_at state).any? do |attr|
            metadata_relevant_attribute_changed?(attr)
          end
        end

        def should_populate_user_metadata?
          %w(created_at).any? do |attr|
            metadata_relevant_attribute_changed?(attr)
          end
        end
      end
    end
  end
end
