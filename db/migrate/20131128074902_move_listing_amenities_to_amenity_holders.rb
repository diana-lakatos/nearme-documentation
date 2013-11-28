class MoveListingAmenitiesToAmenityHolders < ActiveRecord::Migration

  class Listing < ActiveRecord::Base
    has_many :amenity_holders, as: :holder
  end

  class Amenity < ActiveRecord::Base
  end

  class ListingAmenity < ActiveRecord::Base
    belongs_to :listing
    belongs_to :amenity
  end

  class AmenityHolder < ActiveRecord::Base
    belongs_to :amenity
    belongs_to :holder, polymorphic: true
  end

  def up
    ListingAmenity.all.each do |la|
      AmenityHolder.create({
        amenity_id: la.amenity_id,
        holder_id: la.listing_id,
        holder_type: 'Listing'
      })
    end

    drop_table :listing_amenities
  end

  def down
  end
end
