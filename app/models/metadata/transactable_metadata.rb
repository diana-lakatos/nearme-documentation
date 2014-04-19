module Metadata
  module TransactableMetadata
    extend ActiveSupport::Concern

    included do

      after_commit :location_populate_photos_metadata!, :if => lambda { |l| l.should_populate_location_photos_metadata? }
      after_commit :creator_populate_listings_metadata!, :if => lambda { |l| l.should_populate_creator_listings_metadata? }
      after_commit :populate_listing_type_name_metadata!, :if => lambda { |l| l.metadata_relevant_attribute_changed?("listing_type_id") }
      delegate :populate_photos_metadata!, to: :location, :prefix => true
      delegate :populate_listings_metadata!, to: :creator, :prefix => true

      def populate_listing_type_name_metadata!
        update_metadata({ :listing_type_name => listing_type.try(:name) })
      end

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
