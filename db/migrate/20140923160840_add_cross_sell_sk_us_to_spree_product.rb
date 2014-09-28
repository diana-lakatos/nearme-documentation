class AddCrossSellSkUsToSpreeProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :cross_sell_skus, :text, array: true, default: []
  end
end
