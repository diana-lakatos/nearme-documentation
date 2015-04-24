class AddExclusivePriceCentsToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :exclusive_price_cents, :integer, default: 0
    add_column :transactable_types, :action_exclusive_price, :boolean, default: false
  end
end
