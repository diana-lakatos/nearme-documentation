class AddAveragesColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :left_by_seller_average_rating, :float, default: 0.0
    add_column :users, :left_by_buyer_average_rating, :float, default: 0.0
    Instance.find_each do |i|
      i.set_context!
      puts "Populating average ratings for users in #{i.name}"
      User.find_each do |u|
        u.recalculate_left_as_buyer_average_rating!
        u.recalculate_left_as_seller_average_rating!
      end
    end
  end

  def down
    remove_column :users, :left_by_seller_average_rating
    remove_column :users, :left_by_buyer_average_rating
  end
end
