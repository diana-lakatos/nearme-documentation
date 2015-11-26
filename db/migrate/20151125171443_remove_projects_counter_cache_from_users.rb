class RemoveProjectsCounterCacheFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :projects_count, :integer
  end
end
