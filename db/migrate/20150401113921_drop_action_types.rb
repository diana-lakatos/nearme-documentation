class DropActionTypes < ActiveRecord::Migration
  def up
    drop_table :action_types
    drop_table :transactable_type_actions
  end

  def down
    create_table :action_types do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :transactable_type_actions do |t|
      t.integer :action_type_id, index: true
      t.integer :transactable_type_id, index: true
      t.integer :instance_id, index: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
