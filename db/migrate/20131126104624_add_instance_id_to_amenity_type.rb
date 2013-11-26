class AddInstanceIdToAmenityType < ActiveRecord::Migration
  def change
    add_column :amenity_types, :instance_id, :integer
    add_index :amenity_types, :instance_id

    AmenityType.update_all(instance_id: 1)
  end
end
