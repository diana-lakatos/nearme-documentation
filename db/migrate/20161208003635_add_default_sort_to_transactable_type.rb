class AddDefaultSortToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :default_sort_by, :string
  end
end
