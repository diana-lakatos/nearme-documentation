class AddPositionToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :position, :integer, default: 0
  end
end
