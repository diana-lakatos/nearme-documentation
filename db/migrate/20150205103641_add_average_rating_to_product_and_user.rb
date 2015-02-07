class AddAverageRatingToProductAndUser < ActiveRecord::Migration
  def change
     add_column :spree_products, :average_rating, :float, :default => 0.0
     add_column :users, :average_rating, :float, :default => 0.0
  end
end
