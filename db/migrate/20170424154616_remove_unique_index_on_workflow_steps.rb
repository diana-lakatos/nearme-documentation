# frozen_string_literal: true
class RemoveUniqueIndexOnWorkflowSteps < ActiveRecord::Migration
  def up
    remove_index :workflow_steps,
                 name: 'index_workflow_steps_on_assoc_class_and_instance_and_deleted'
  end

  def down
    add_index :workflow_steps, %w(associated_class instance_id deleted_at),
              name: 'index_workflow_steps_on_assoc_class_and_instance_and_deleted',
              unique: true,
              using: :btree
  end
end
