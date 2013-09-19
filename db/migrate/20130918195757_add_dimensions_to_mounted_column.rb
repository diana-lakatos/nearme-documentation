class AddDimensionsToMountedColumn < ActiveRecord::Migration
  def change
    add_column :users, :avatar_original_height, :integer
    add_column :users, :avatar_original_width, :integer
    add_column :photos, :image_original_height, :integer
    add_column :photos, :image_original_width, :integer
  end
end
