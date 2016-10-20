class AddBothSideConfirmationToTransactableTypeActionTypes < ActiveRecord::Migration
  def change
    add_column :transactable_type_action_types, :both_side_confirmation, :boolean, default: false
  end
end
