class AddCapacityToListing < ActiveRecord::Migration
  def change
    add_column :listings, :capacity, :integer
  end
end
