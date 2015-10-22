class ChangeRatingsUniqueIndex < ActiveRecord::Migration
  def up
    remove_index :reviews, 'rating_system_id_and_reviewable'
    add_index :reviews, [:rating_system_id, :reviewable_id, :reviewable_type, :deleted_at], name: 'index_reviews_on_rating_system_id_and_reviewable_and_deleted_at', unique: true
  end

  def down
    remove_index :reviews, 'rating_system_id_and_reviewable_and_deleted_at'
    add_index :reviews, [:rating_system_id, :reviewable_id, :reviewable_type], name: 'index_reviews_on_rating_system_id_and_reviewable', unique: true
  end
end
