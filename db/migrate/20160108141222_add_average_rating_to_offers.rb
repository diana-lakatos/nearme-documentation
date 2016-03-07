class AddAverageRatingToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :average_rating, :decimal
  end
end
