class AddSlugToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :slug, :string
    add_index :locations, :slug
  end

  def down
    remove_column :locations, :slug
  end 
end
