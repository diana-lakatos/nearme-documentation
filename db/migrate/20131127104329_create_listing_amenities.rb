class CreateListingAmenities < ActiveRecord::Migration
  def change
    create_table :listing_amenities do |t|
      t.references :listing
      t.references :amenity

      t.timestamps
    end
    add_index :listing_amenities, :listing_id
    add_index :listing_amenities, :amenity_id
  end
end
