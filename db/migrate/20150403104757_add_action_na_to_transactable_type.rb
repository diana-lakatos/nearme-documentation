class AddActionNaToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :action_na, :boolean, default: false
  end
end
