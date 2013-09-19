class RemoveInstanceIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :instance_id
  end
end
