class AddFeaturedToUsersProjectsAndTopics < ActiveRecord::Migration
  def change
    add_column :users, :featured, :boolean, default: false
    add_column :projects, :featured, :boolean, default: false
    add_column :topics, :featured, :boolean, default: false
  end
end
