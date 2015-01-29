class CreateUserBlogPosts < ActiveRecord::Migration
  def change
    create_table :user_blog_posts do |t|
      t.integer :user_id, index: true
      t.string :title
      t.string :slug
      t.string :hero_image
      t.text :content
      t.text :excerpt
      t.date :published_at
      t.string :author_name
      t.text :author_biography
      t.string :logo

      t.timestamps
    end
  end
end
