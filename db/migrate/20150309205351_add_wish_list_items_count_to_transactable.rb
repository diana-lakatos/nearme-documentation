class AddWishListItemsCountToTransactable < ActiveRecord::Migration
  def change
    add_column :transactables, :wish_list_items_count, :integer, default: 0
  end
end
