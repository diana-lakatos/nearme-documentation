class AddSlugToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :slug, :string
    add_index :locations, :slug
    Location.find_each(&:save)
  end

  def down
    remove_column :locations, :slug
  end 
end
