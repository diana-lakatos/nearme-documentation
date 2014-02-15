class ChangeUserRelationshipFollowerAndFollowedIndex < ActiveRecord::Migration
  def up
    remove_index "user_relationships", ["follower_id", "followed_id"]
    add_index "user_relationships", ["follower_id", "followed_id", "deleted_at"], :name => "index_user_relationships_on_follower_id_and_followed_id", :unique => true
  end

  def down
    remove_index "user_relationships", ["follower_id", "followed_id", "deleted_at"]
    add_index "user_relationships", ["follower_id", "followed_id"], :name => "index_user_relationships_on_follower_id_and_followed_id", :unique => true
  end
end
