class AddWishListToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :wish_list_items_count, :integer, default: 0
  end
end
