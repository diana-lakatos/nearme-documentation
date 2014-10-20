class CreateWorkflowAlerts < ActiveRecord::Migration
  def change

    create_table :workflows do |t|
      t.string :name
      t.string :associated_event
      t.integer :instance_id, index: true
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :workflow_alerts do |t|
      t.string :name
      t.string :alert_type
      t.string :recipient_type
      t.string :template_path
      t.integer :workflow_id, index: true
      t.integer :instance_id, index: true
      t.text :options
      t.datetime :deleted_at
      t.timestamps
    end

    add_column :email_templates, :custom_email, :boolean, default: false
  end
end
