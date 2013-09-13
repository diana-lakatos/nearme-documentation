class AddEnabledToListing < ActiveRecord::Migration
  def change
    add_column :listings, :enabled, :boolean, :default => true
  end
end
