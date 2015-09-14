class FixReviewsIndexes < ActiveRecord::Migration
  def up
    remove_index :reviews, :reviewable_id
    remove_index :reviews, :reviewable_type
    add_index :reviews, [:rating_system_id, :reviewable_id, :reviewable_type], name: 'index_reviews_on_rating_system_id_and_reviewable', unique: true
  end

  def down
    add_index :reviews, :reviewable_id
    add_index :reviews, :reviewable_type
    remove_index :reviews, [:rating_system_id, :reviewable_id, :reviewable_type], name: 'index_reviews_on_rating_system_id_and_reviewable'
  end
end
