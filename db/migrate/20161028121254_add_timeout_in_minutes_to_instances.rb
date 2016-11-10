class AddTimeoutInMinutesToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :timeout_in_minutes, :integer, default: 0, null: false
  end
end
