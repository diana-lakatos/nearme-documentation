class RenameDjInstanceNameToInstanceId < ActiveRecord::Migration
  def change
    rename_column :delayed_jobs, :instance_name, :instance_id
  end
end
