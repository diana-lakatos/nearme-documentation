class CreateTransactablesUserStatusUpdates < ActiveRecord::Migration
  def change
    create_table :transactables_user_status_updates do |t|
      t.integer :transactable_id
      t.integer :user_status_update_id
    end

    add_index :transactables_user_status_updates, [:transactable_id, :user_status_update_id], name: :transactable_usu_id
  end
end
