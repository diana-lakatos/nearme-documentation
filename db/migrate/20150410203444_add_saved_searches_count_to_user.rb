class AddSavedSearchesCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :saved_searches_count, :integer, default: 0
    add_index :users, %i(saved_searches_alerts_frequency saved_searches_count ), name: 'index_users_on_saved_search_attrs'
  end
end
