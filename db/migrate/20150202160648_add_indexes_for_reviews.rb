class AddIndexesForReviews < ActiveRecord::Migration
  def change
    add_index :reviews, [:reviewable_id, :reviewable_type]
  end
end
