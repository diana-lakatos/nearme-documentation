class CreateAuditTrailTables < ActiveRecord::Migration
  def change
    create_table :workflow_alert_logs do |t|
      t.integer :instance_id
      t.integer :workflow_alert_id, index: true
      t.integer :workflow_alert_weekly_aggregated_log_id, index: true
      t.integer :workflow_alert_monthly_aggregated_log_id, index: true
      t.string :alert_type
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :workflow_alert_logs, [:instance_id, :alert_type]

    create_table :workflow_alert_weekly_aggregated_logs do |t|
      t.integer :instance_id
      t.integer :year
      t.integer :week_number
      t.integer :email_count, :integer, :null => false, :default => 0
      t.integer :sms_count, :integer, :null => false, :default => 0
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :workflow_alert_weekly_aggregated_logs, [:instance_id, :year, :week_number], name: 'wamal_instance_id_year_week_number_index', unique: true

    create_table :workflow_alert_monthly_aggregated_logs do |t|
      t.integer :instance_id, index: true
      t.integer :workflow_alert_id, index: true
      t.integer :year
      t.integer :month
      t.integer :email_count, :integer, :null => false, :default => 0
      t.integer :sms_count, :integer, :null => false, :default => 0
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :workflow_alert_monthly_aggregated_logs, [:instance_id, :year, :month], name: 'wamal_instance_id_year_month_index', unique: true
  end
end
