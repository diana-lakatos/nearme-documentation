class AddMasterLockToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :master_lock, :datetime
  end
end
