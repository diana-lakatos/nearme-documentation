class RemoveFieldsFromUserBlogs < ActiveRecord::Migration
  def up
    remove_columns :user_blogs, :header_image, :header_motto, :header_text, :facebook_app_id
  end

  def down
    add_column :user_blogs, :header_image, :string
    add_column :user_blogs, :header_motto, :string
    add_column :user_blogs, :header_text, :string
    add_column :user_blogs, :facebook_app_id, :string
  end
end
