class CreateGroupProjects < ActiveRecord::Migration
  def change
    create_table :group_projects do |t|
      t.integer  :instance_id
      t.integer  :group_id
      t.integer  :project_id
      t.timestamps null: false
    end
  end
end
