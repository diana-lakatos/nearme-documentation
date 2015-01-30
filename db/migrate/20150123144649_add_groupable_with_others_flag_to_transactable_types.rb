class AddGroupableWithOthersFlagToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :groupable_with_others, :boolean, default: true
  end
end
