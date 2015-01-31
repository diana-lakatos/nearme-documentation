class RenameUserBlogPostLogoToAuthorAvatar < ActiveRecord::Migration
  def up
    rename_column :user_blog_posts, :logo, :author_avatar_img
  end

  def down
    rename_column :user_blog_posts, :author_avatar_img, :logo
  end
end
