class AddUserBlogsEnabledToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :user_blogs_enabled, :boolean, default: false
  end
end
