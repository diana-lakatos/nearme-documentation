class AddDeletedAtToAmenityHolder < ActiveRecord::Migration
  def change
    add_column :amenity_holders, :deleted_at, :datetime
  end
end
