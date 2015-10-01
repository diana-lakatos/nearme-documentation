class CreateProjectCollaborators < ActiveRecord::Migration
  def change
    create_table :project_collaborators do |t|
      t.integer :instance_id
      t.integer :user_id
      t.integer :project_id
      t.datetime :approved_at
      t.datetime :deleted_at
      t.timestamps null: false
    end

    add_index :project_collaborators, :instance_id
    add_index :project_collaborators, :user_id
    add_index :project_collaborators, :project_id
  end
end
