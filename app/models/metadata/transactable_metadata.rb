module Metadata
  module TransactableMetadata
    extend ActiveSupport::Concern

    included do

      attr_accessor :skip_metadata
      after_commit :location_populate_photos_metadata!, :if => lambda { |l| !l.skip_metadata && l.should_populate_location_photos_metadata? }
      after_commit :creator_populate_listings_metadata!, :if => lambda { |l| !l.skip_metadata && l.should_populate_creator_listings_metadata? }
      delegate :populate_photos_metadata!, to: :location, :prefix => true
      delegate :populate_listings_metadata!, to: :creator, :prefix => true

      def populate_photos_metadata!
        update_metadata({ :photos_metadata => build_photos_metadata_array })
        location_populate_photos_metadata!
      end

      def build_photos_metadata_array
        self.reload.photos.inject([]) do |array, photo|
          array << photo.to_listing_metadata
          array
        end
      end

      def should_populate_location_photos_metadata?
        location.present? && %w(name).any? { |attr| metadata_relevant_attribute_changed?(attr) }
      end

      def should_populate_creator_listings_metadata?
        self.destroyed? || %w(id draft).any? { |attr| metadata_relevant_attribute_changed?(attr) }
      end

    end

  end
end
