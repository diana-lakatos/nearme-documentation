class AddPhotosCountToListing < ActiveRecord::Migration

  class Listing < ActiveRecord::Base
    has_many :photos
  end

  class Photo < ActiveRecord::Base
    belongs_to :listing
  end

  def change
    add_column :listings, :photos_count, :integer, default: 0

    Listing.includes(:photos).each do |listing|
      listing.update_column(:photos_count, listing.photos.count)
    end
  end
end
