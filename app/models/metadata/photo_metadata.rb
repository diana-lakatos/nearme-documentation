# frozen_string_literal: true
module Metadata
  module PhotoMetadata
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_metadata
      after_commit :listing_populate_photos_metadata!, if: ->(p) { !p.skip_metadata && p.should_populate_metadata? }
      after_update :listing_populate_photos_metadata!, if: ->(p) { !p.skip_metadata && p.should_populate_metadata? }
      # We need this because on restore the other callbacks are not called and metadata is not restored
      after_restore :listing_populate_photos_metadata!, if: ->(p) { !p.skip_metadata }

      def should_populate_metadata?
        deleted? || (listing.present? && relevant_attribute_changed?)
      end

      def relevant_attribute_changed?
        %w(deleted_at caption position owner_id image crop_x crop_y crop_h crop_w rotation_angle image_original_url image_transformation_data).any? do |attr|
          metadata_relevant_attribute_changed?(attr)
        end
      end

      def to_listing_metadata
        {
          listing_name: listing.name,
          original: image.url,
          space_listing: image.url(:space_listing),
          golden:  image.url(:golden),
          large: image.url(:large),
          caption: caption
        }
      end

      def listing_populate_photos_metadata!
        listing.try(:populate_photos_metadata!)
      end

      def to_location_metadata
        to_listing_metadata
      end
    end
  end
end
