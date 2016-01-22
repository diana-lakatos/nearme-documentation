class AddFeaturedToServicesProductsLocations < ActiveRecord::Migration
  def change
  	add_column :spree_products, :featured, :boolean, default: false
  	add_column :transactables, :featured, :boolean, default: false
  end
end
