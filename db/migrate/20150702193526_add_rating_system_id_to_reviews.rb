class AddRatingSystemIdToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :rating_system_id, :integer, index: true
  end
end
