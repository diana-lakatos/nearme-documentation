class EnableDeltaIndexingForListings < ActiveRecord::Migration
  def up
    add_column :listings, :delta, :boolean, :default => true, :null => false
  end

  def down
    remove_column :listings, :delta
  end
end
