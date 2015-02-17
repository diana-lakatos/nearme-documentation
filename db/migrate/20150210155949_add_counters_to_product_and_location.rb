class AddCountersToProductAndLocation < ActiveRecord::Migration
  def change
    add_column :spree_products, :wish_list_items_count, :integer, default: 0
    add_column :locations, :wish_list_items_count, :integer, default: 0
  end
end
