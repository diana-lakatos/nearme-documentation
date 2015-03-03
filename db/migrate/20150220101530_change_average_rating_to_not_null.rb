class ChangeAverageRatingToNotNull < ActiveRecord::Migration
  def up
    %i(transactables spree_products users).each do |table_name|
      change_column table_name, :average_rating, :float, default: 0.0, null: false
    end
  end

  def down
    %i(transactables spree_products users).each do |table_name|
      change_column table_name, :average_rating, :float, default: 0.0
    end
  end
end
