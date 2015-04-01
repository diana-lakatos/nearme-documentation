class AddTypeToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :type, :string
  end
end
