class AddMultipleRootsCategoriesToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :multiple_root_categries, :boolean
  end
end
