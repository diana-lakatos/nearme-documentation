class AddVersionsGeneratedAtFields < ActiveRecord::Migration
  def change
    add_column :user_blog_posts, :author_avatar_img_versions_generated_at, :timestamp
    add_column :ckeditor_assets, :data_versions_generated_at, :timestamp
    add_column :groups, :cover_image_versions_generated_at, :timestamp
    add_column :links, :image_versions_generated_at, :timestamp
    add_column :blog_posts, :author_avatar_versions_generated_at, :timestamp
  end
end
