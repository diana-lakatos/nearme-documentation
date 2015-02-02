class ChangePublishedAtToDateTime < ActiveRecord::Migration
  def up
    change_column :user_blog_posts, :published_at, :datetime
  end

  def down
    change_column :user_blog_posts, :published_at, :date
  end
end
