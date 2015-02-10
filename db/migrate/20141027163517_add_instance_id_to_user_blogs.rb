class AddInstanceIdToUserBlogs < ActiveRecord::Migration
  def change
    add_column :user_blogs, :instance_id, :integer
  end
end
