class AddEmailToProjectCollaborators < ActiveRecord::Migration
  def change
    add_column :project_collaborators, :email, :string
  end
end
