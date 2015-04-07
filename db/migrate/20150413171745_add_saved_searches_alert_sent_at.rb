class AddSavedSearchesAlertSentAt < ActiveRecord::Migration
  def change
    add_column :users, :saved_searches_alert_sent_at, :datetime
    remove_index :users, name: :index_users_on_saved_search_attrs
    add_index :users,
      %i(saved_searches_alerts_frequency saved_searches_count saved_searches_alert_sent_at),
      name: :index_users_on_saved_search_attrs
  end
end
