class AddAllowDraftsToTransactableTypesActionTypes < ActiveRecord::Migration
  def change
    add_column :transactable_type_action_types, :allow_drafts, :boolean, null: false, default: false
  end
end
