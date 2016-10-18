class AuthaddHeroImageVersionsGeneratedAtToUserBlogPosts < ActiveRecord::Migration
  def change
    add_column :user_blog_posts, :hero_image_versions_generated_at, :datetime
  end
end
