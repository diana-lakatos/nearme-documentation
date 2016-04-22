class CreateInappropriateReports < ActiveRecord::Migration
  def change
    create_table :inappropriate_reports do |t|
      t.integer :user_id
      t.integer :instance_id
      t.integer :reportable_id
      t.string :reportable_type
      t.datetime :deleted_at
      t.string :ip_address
      t.timestamps null: false
    end

    add_index :inappropriate_reports, :user_id
    add_index :inappropriate_reports, :reportable_id
    add_index :inappropriate_reports, [:instance_id, :reportable_id, :reportable_type], name: 'inappropriate_reports_instance_reportable'
    add_index :inappropriate_reports, [:instance_id, :user_id, :reportable_id, :reportable_type], unique: true, where: '(deleted_at IS NULL)', name: 'uniq_inappropriate_instance_user_reports_instance_reportable' 
  end
end
