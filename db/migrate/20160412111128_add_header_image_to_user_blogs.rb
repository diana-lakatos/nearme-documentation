class AddHeaderImageToUserBlogs < ActiveRecord::Migration
  def change
    add_column :user_blogs, :header_image, :string, limit: 255
  end
end
