class AddLastGeolocatedLocationToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_geolocated_location_longitude, :float
    add_column :users, :last_geolocated_location_latitude, :float
  end
end
