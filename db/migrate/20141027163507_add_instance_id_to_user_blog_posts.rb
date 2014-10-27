class AddInstanceIdToUserBlogPosts < ActiveRecord::Migration
  def change
    add_column :user_blog_posts, :instance_id, :integer
  end
end
