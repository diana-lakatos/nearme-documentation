class AddPricePerUnitToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :action_price_per_unit, :boolean, default: false
  end
end
