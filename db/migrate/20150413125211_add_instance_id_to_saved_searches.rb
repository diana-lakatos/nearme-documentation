class AddInstanceIdToSavedSearches < ActiveRecord::Migration
  def change
    add_column :saved_searches, :instance_id, :integer, index: true
  end
end
