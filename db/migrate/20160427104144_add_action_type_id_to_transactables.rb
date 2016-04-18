class AddActionTypeIdToTransactables < ActiveRecord::Migration
  def up
    add_column :transactables, :action_type_id, :integer
    Transactable.update_all("action_type_id = (SELECT tat.id FROM transactable_action_types tat WHERE tat.transactable_id = transactables.id AND tat.enabled IS TRUE AND tat.deleted_at IS NULL LIMIT 1)")
  end

  def down
    remove_column :transactables, :action_type_id
  end
end
