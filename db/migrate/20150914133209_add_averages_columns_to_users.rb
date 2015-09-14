class AddAveragesColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :left_by_seller_average_rating, :float, default: 0.0
    add_column :users, :left_by_buyer_average_rating, :float, default: 0.0
  end

  def down
    remove_column :users, :left_by_seller_average_rating
    remove_column :users, :left_by_buyer_average_rating
  end
end
