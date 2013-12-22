class AddPhotosCountToListing < ActiveRecord::Migration

  class Listing < ActiveRecord::Base
    has_many :photos
  end

  class Photo < ActiveRecord::Base
    belongs_to :listing
  end

  def change
    add_column :listings, :photos_count, :integer, default: 0

    Listing.scoped.each do |listing|
      listing.update_column(:photos_count, listing.photos.where('photos.deleted_at IS NULL').count)
    end
  end
end
