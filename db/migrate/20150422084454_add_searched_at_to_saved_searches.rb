class AddSearchedAtToSavedSearches < ActiveRecord::Migration
  def change
    add_column :saved_searches, :last_viewed_at, :datetime
  end
end
