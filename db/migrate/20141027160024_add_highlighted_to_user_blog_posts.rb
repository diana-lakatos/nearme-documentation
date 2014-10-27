class AddHighlightedToUserBlogPosts < ActiveRecord::Migration
  def change
    add_column :user_blog_posts, :highlighted, :boolean, default: false
  end
end
