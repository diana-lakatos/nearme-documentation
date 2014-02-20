class AddListingsPublicToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :listings_public, :boolean, default: true
  end
end
