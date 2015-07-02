class AddLastIndexJobIdToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :last_index_job_id, :integer
  end
end
