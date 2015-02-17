class AddWishListIconSetToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :wish_lists_icon_set, :string, default: 'heart'
  end
end
