class AddSearchableToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :searchable, :boolean, default: true
  end
end
