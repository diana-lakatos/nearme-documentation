module Metadata
  module TransactableMetadata
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_metadata
      after_commit :location_populate_photos_metadata!, if: ->(l) { !l.skip_metadata && l.should_populate_location_photos_metadata? }
      delegate :populate_photos_metadata!, to: :location, prefix: true, allow_nil: true

      def populate_photos_metadata!
        update_metadata(photos_metadata: build_photos_metadata_array)
        location_populate_photos_metadata!
      end

      def build_photos_metadata_array
        reload.photos.inject([]) do |array, photo|
          array << photo.to_listing_metadata
          array
        end
      end

      def should_populate_location_photos_metadata?
        location.present? && %w(name location_id).any? { |attr| metadata_relevant_attribute_changed?(attr) }
      end

      def should_populate_creator_listings_metadata?
        self.paranoia_destroyed? || %w(id draft).any? { |attr| metadata_relevant_attribute_changed?(attr) }
      end
    end
  end
end
