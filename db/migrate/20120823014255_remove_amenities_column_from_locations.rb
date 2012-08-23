class RemoveAmenitiesColumnFromLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :amenities
  end

  def down
    add_column :locations, :amenities, :string
  end
end
