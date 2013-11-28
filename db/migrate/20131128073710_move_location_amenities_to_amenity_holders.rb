class MoveLocationAmenitiesToAmenityHolders < ActiveRecord::Migration

  class Location < ActiveRecord::Base
    has_many :amenity_holders, as: :holder
  end

  class Amenity < ActiveRecord::Base
  end

  class LocationAmenity < ActiveRecord::Base
    belongs_to :location
    belongs_to :amenity
  end

  class AmenityHolder < ActiveRecord::Base
    belongs_to :amenity
    belongs_to :holder, polymorphic: true
  end

  def up
    LocationAmenity.all.each do |la|
      AmenityHolder.create({
        amenity_id: la.amenity_id,
        holder_id: la.location_id,
        holder_type: 'Location'
      })
    end

    drop_table :location_amenities
  end

  def down
  end
end
