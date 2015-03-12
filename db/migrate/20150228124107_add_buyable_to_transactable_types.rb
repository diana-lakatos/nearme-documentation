class AddBuyableToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :buyable, :boolean
  end
end
