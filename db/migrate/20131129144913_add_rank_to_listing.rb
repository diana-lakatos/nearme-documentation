class AddRankToListing < ActiveRecord::Migration
  def change
    add_column :listings, :rank, :integer, default: 0
  end
end
