class AddWishListItemsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :wish_list_items_count, :integer, default: 0
  end
end
