class AddWishListsEnabledToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :wish_lists_enabled, :boolean, default: false
  end
end
