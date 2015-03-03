class ChangeAverageRatingForUsers < ActiveRecord::Migration
  def change
    add_column :users, :buyer_average_rating, :float, default: 0.0, null: false
    rename_column :users, :average_rating, :seller_average_rating
  end
end
