class AddProjectsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :projects_count, :integer
    User.find_each { |user| User.reset_counters(user.id, :projects) }
  end
end
