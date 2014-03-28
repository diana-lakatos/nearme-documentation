class AddExcerptToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :excerpt, :text
  end
end
