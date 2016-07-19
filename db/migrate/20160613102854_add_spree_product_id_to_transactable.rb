class AddSpreeProductIdToTransactable < ActiveRecord::Migration
  def change
    add_column :transactables, :spree_product_id, :integer
  end
end
