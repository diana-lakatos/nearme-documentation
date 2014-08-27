class DropListings < ActiveRecord::Migration
  def change
    drop_table :listings
  end
end
