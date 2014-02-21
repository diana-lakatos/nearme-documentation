module Metadata
  module ListingTypeMetadata
    extend ActiveSupport::Concern

    included do

      after_commit :populate_listings_metadata!, :if => lambda { |lt| lt.metadata_relevant_attribute_changed?("name") }

      def populate_listings_metadata!
        listings.reload.each { |listing| listing.populate_listing_type_name_metadata! }
      end

    end

  end
end
