class CreateWorkflowSteps < ActiveRecord::Migration
  def change
    create_table :workflow_steps do |t|
      t.string :name
      t.string :associated_event
      t.integer :instance_id, index: true
      t.integer :workflow_id, index: true
      t.datetime :deleted_at
      t.timestamps
    end

    remove_column :workflows, :associated_event, :string
    add_column :workflows, :events_metadata, :text
    rename_column :workflow_alerts, :workflow_id, :workflow_step_id
    add_column :workflows, :workflow_type, :string
  end
end
