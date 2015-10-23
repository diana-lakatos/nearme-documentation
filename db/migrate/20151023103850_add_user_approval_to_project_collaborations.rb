class AddUserApprovalToProjectCollaborations < ActiveRecord::Migration
  def up
    rename_column :project_collaborators, :approved_at, :approved_by_owner_at
    add_column :project_collaborators, :approved_by_user_at, :datetime

    ProjectCollaborator.unscoped.update_all("approved_by_user_at = COALESCE(approved_by_owner_at, NOW())")
  end

  def down
    rename_column :project_collaborators, :approved_by_owner_at, :approved_at
    remove_column :project_collaborators, :approved_by_user_at
  end
end
