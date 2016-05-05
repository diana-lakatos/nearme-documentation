class AddSingleLocationToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :single_location, :boolean, default: false, null: false
  end
end
