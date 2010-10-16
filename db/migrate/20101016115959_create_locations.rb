class CreateLocations < ActiveRecord::Migration
  def self.up
    # based off of http://code.google.com/apis/maps/documentation/geocoding/
    columns = [ :name, :street_address, :route, :intersection, :political, :country, :administrative_area_level_1,
                :administrative_area_level_2, :administrative_area_level_3, :colloquial_area, :locality,
                :sublocality, :neighborhood, :premise, :subpremise, :postal_code, :natural_feature,
                :airport, :park, :point_of_interest, :post_box, :street_number, :floor, :room ]
    create_table :locations do |t|
      t.float :latitude
      t.float :longitude
      columns.each do |column|
        t.string column
      end
      t.timestamps
    end
    columns.each do |column|
      add_index :locations, column
    end
  end

  def self.down
    drop_table :locations
  end
end
