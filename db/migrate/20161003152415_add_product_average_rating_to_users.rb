class AddProductAverageRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :product_average_rating, :float, default: 0.0
  end
end
