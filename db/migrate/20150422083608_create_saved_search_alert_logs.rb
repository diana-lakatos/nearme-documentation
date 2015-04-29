class CreateSavedSearchAlertLogs < ActiveRecord::Migration
  def change
    create_table :saved_search_alert_logs do |t|
      t.references :instance, index: true
      t.references :saved_search
      t.integer :results_count
      t.timestamps
    end

    add_index :saved_search_alert_logs, [:saved_search_id, :created_at]
  end
end
