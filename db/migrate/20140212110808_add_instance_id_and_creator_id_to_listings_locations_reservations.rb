class AddInstanceIdAndCreatorIdToListingsLocationsReservations < ActiveRecord::Migration
  def change
    add_column :listings, :instance_id, :integer
    add_column :locations, :instance_id, :integer
    add_column :reservations, :instance_id, :integer
    add_column :listings, :creator_id, :integer
    add_column :locations, :creator_id, :integer
    add_column :reservations, :creator_id, :integer
    add_column :listings, :administrator_id, :integer
    add_column :reservations, :administrator_id, :integer

    add_index :listings, :instance_id
    add_index :locations, :instance_id
    add_index :reservations, :instance_id
    add_index :listings, :creator_id
    add_index :locations, :creator_id
    add_index :reservations, :creator_id
    add_index :listings, :administrator_id
    add_index :reservations, :administrator_id
  end
end
