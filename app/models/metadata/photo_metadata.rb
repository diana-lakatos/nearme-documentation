module Metadata
  module PhotoMetadata
    extend ActiveSupport::Concern

    included do

      delegate :populate_photos_metadata!, :to => :listing, :prefix => true

      after_commit :listing_populate_photos_metadata!, :if => lambda { |p| p.should_populate_metadata? }
      after_commit :update_counter!

      def should_populate_metadata?
        deleted? || (listing.present? && relevant_attribute_changed?)
      end

      def relevant_attribute_changed?
        %w(deleted_at caption position listing_id image crop_x crop_y crop_h crop_w rotation_angle image_original_url image_transformation_data).any? do |attr| 
          metadata_relevant_attribute_changed?(attr) 
        end
      end

      def update_counter!
        listing.reload.update_column(:photos_count, listing.photos.count) if listing.present?
      end

      def to_listing_metadata
        { 
          space_listing: image_url(:space_listing),
          golden:  image_url(:golden) ,
          large: image_url(:large),
        }
      end

      def to_location_metadata
        to_listing_metadata.merge(listing_name: listing.name, caption: caption)
      end

    end

  end
end
