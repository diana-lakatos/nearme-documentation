module Metadata
  module LocationMetadata
    extend ActiveSupport::Concern

    included do
      def populate_photos_metadata!
        update_metadata(photos_metadata: build_photos_metadata_array) unless transactable_type && transactable_type.skip_location
      end

      def build_photos_metadata_array
        reload.photos.inject([]) do |array, photo|
          array << photo.to_location_metadata
          array
        end
      end
    end
  end
end
