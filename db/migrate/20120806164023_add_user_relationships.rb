class AddUserRelationships < ActiveRecord::Migration
  def up
    create_table "user_relationships" do |t|
      t.integer  "follower_id"
      t.integer  "followed_id"
      t.datetime "created_at",  :null => false
      t.datetime "updated_at",  :null => false
      t.datetime "deleted_at"
    end

    add_index "user_relationships", ["followed_id"], :name => "index_user_relationships_on_followed_id"
    add_index "user_relationships", ["follower_id", "followed_id"], :name => "index_user_relationships_on_follower_id_and_followed_id", :unique => true
    add_index "user_relationships", ["follower_id"], :name => "index_user_relationships_on_follower_id"
  end

  def down
    remove_index "user_relationships", :name => "index_user_relationships_on_follower_id"
    remove_index "user_relationships", :name => "index_user_relationships_on_follower_id_and_followed_id"
    remove_index "user_relationships", :name => "index_user_relationships_on_followed_id"

    drop_table "user_relationships"
  end
end
