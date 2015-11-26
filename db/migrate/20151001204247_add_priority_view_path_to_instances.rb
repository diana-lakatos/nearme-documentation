class AddPriorityViewPathToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :priority_view_path, :string, default: nil
  end
end
