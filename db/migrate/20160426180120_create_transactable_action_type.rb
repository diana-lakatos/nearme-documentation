class CreateTransactableActionType < ActiveRecord::Migration
  def change
    create_table :transactable_action_types do |t|
      t.integer :instance_id, index: true
      t.integer :transactable_id
      t.integer :transactable_type_action_type_id
      t.integer :availability_template_id
      t.boolean :enabled
      t.string :type
      t.integer :minimum_booking_minutes
      t.boolean :no_action
      t.boolean :action_rfq

      t.datetime :deleted_at
      t.timestamps

      t.index [:instance_id, :transactable_id, :type], name: 'transactable_action_types_main_idx'
    end
  end
end
