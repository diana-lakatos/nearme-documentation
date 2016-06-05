class CreateProjectsUserStatusUpdates < ActiveRecord::Migration
  def change
    create_table :projects_user_status_updates do |t|
      t.integer :project_id
      t.integer :user_status_update_id
    end

    add_index :projects_user_status_updates, [:project_id, :user_status_update_id], name: :project_usu_id
  end
end
