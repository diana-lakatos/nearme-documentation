class AddSavedSearchAlertsFrequencyToUser < ActiveRecord::Migration
  def change
    add_column :users, :saved_searches_alerts_frequency, :string, default: 'daily'
  end
end
