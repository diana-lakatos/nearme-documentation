class AddInstanceNameToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :instance_name, :string
  end
end
